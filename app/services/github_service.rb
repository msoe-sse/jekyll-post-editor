require 'octokit'
require 'base64'

##
# This module contains all operations involving interacting with the GitHub API

module GithubService
  class << self
    CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
    CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

    ##
    # This method authenticates a GitHub user given their username and password
    # and checks to see if the user belongs to the msoe-sse github orginization.
    #
    # Returns a new oauth token for the Post Editor to use or an existing oauth token
    # that the Post Editor previously created. If the login credentials are incorrect
    # the symbol :unauthorized is returned and if the user is not apart of the msoe-sse
    # GitHub orginization the symbol :not_in_organization is returned
    # 
    # Params:
    # +username+:: a user's GitHub username
    # +password+:: a user's GitHub password
    def authenticate(username, password)
      client = Octokit::Client.new(:login => username, :password => password)
      begin
        if not client.organization_member?(Rails.configuration.github_org, client.user.login)
          return :not_in_organization
        else
          return get_oauth_token(client)
        end
      rescue Octokit::Unauthorized
        return :unauthorized
      end
    end

    ##
    # This method get the authorization url which authorizes the post editor app
    # to use a user's GitHub account. The scope is write:org so that we're able
    # to make changes to the msoe-sse/mseo-sse.github.io repository which requires
    # write access to an orginization's repository
    def get_authorization_url
      client = Octokit::Client.new
      client.authorize_url(CLIENT_ID, :scope => 'write:org')
    end

    ##
    # This method exchanges a session code, which gets created after a user authorizes
    # the app to use their GitHub account, and fetches their oauth access token
    # to be used when making GitHub API requests with the post editor
    # 
    # Params:
    # +session_code+:: a GitHub session code
    def get_oauth_access_token(session_code)
      Octokit.exchange_code_for_token(session_code, CLIENT_ID, CLIENT_SECRET)
    end

    ##
    # This method checks to see if a oauth access token is valid for use in the post editor.
    # A token could no longer be valid if it's been revoked, which means we need to start
    # the oauth authentication flow again.
    #
    # Params:
    # +access_token+:: a GitHub oauth access token
    def check_access_token(access_token)
      client = Octokit::Client.new(:client_id => CLIENT_ID, :client_secret => CLIENT_SECRET)
      begin
        client.check_application_authorization access_token
        return true
      rescue Octokit::Unauthorized
        return false
      end
    end

    ##
    # This method fetches all the markdown contents of all the posts on the SSE website
    # and returns a list of models representing a Post
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    def get_all_posts(oauth_token)
      result = []
      client = Octokit::Client.new(:access_token => oauth_token)
      posts = client.contents(get_full_repo_name, :path => '_posts')
      posts.each do |post|
        post_api_response = client.contents(get_full_repo_name, :path => post.path)
        text_contents = Base64.decode64(post_api_response.content)
        result << PostFactory.create_post(text_contents)
      end
      result
    end
    
    ##
    # This method fetches a single post from the SSE website given a post title
    # and returns a Post model
    # 
    # Params:
    # +oauth_token+::a user's oauth access token
    # +title+:: A title of a SSE website post
    def get_post_by_title(oauth_token, title)
      get_all_posts(oauth_token).find { |x| x.title == title }
    end

    def submit_post(post_markdown, author)
      #TODO: Authentication with client = Octokit::Client.new(:access_token => "<your 40 char token>")
      #TODO: Create Branch for new post
      #TODO: Commit and push new post
      #TODO: Create pull request for new post
    end

    private
    def get_oauth_token(client)
      authorization = client.authorizations.find { |x| x[:app][:name] == Rails.configuration.oauth_token_name}
      if authorization
        return authorization[:hashed_token]
      end
      client.create_authorization(:scopes => ['user'], :note => Rails.configuration.oauth_token_name)
    end

    def get_full_repo_name
      "#{Rails.configuration.github_org}/#{Rails.configuration.github_repo_name}"
    end
  end
end