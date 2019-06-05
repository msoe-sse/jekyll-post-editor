require 'octokit'
require 'base64'

##
# This module contains all operations involving interacting with the GitHub API

module GithubService
  class << self
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
          return _get_oauth_token(client)
        end
      rescue Octokit::Unauthorized
        return :unauthorized
      end
    end

    ##
    # This method fetches all the markdown contents of all the posts on the SSE website
    # and returns a list of models representing a Post
    def get_all_posts
      result = []
      posts = Octokit.contents(_get_full_repo_name, :path => '_posts')
      posts.each do |post|
        post_api_response = Octokit.contents(_get_full_repo_name, :path => post.path)
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
    # +title+:: A title of a SSE website post
    def get_post_by_title(title)
      get_all_posts.find { |x| x.title == title }
    end

    def submit_post(post_markdown, author)
      #TODO: Authentication with client = Octokit::Client.new(:access_token => "<your 40 char token>")
      #TODO: Create Branch for new post
      #TODO: Commit and push new post
      #TODO: Create pull request for new post
    end

    #Private Helpers, these methods should not be called outside of this module

    def _get_oauth_token(client)
      authorization = client.authorizations.find { |x| x[:app][:name] == Rails.configuration.oauth_token_name}
      if authorization
        return authorization[:hashed_token]
      end
      client.create_authorization(:scopes => ['user'], :note => Rails.configuration.oauth_token_name)
    end

    def _get_full_repo_name
      "#{Rails.configuration.github_org}/#{Rails.configuration.github_repo_name}"
    end
  end
end