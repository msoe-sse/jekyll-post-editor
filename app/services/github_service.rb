require 'octokit'
require 'base64'

##
# This module contains all operations involving interacting with the GitHub API
module GithubService
  class << self
    CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
    CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

    ##
    # This method get the authorization url which authorizes the post editor app
    # to use a user's GitHub account. The scope is write:org so that we're able
    # to make changes to the msoe-sse/mseo-sse.github.io repository which requires
    # write access to an orginization's repository
    def get_authorization_url
      client = Octokit::Client.new
      client.authorize_url(CLIENT_ID, scope: 'public_repo')
    end

    ##
    # This method exchanges a session code, which gets created after a user authorizes
    # the app to use their GitHub account, and fetches their oauth access token
    # to be used when making GitHub API requests with the post editor
    # 
    # Params:
    # +session_code+:: a GitHub session code
    def get_oauth_access_token(session_code)
      result = Octokit.exchange_code_for_token(session_code, CLIENT_ID, CLIENT_SECRET)
      result[:access_token]
    end

    ##
    # This method checks to see if a oauth access token is valid for use in the post editor.
    # A token could no longer be valid if it's been revoked, which means we need to start
    # the oauth authentication flow again.
    #
    # Params:
    # +access_token+:: a GitHub oauth access token
    def check_access_token(access_token)
      client = Octokit::Client.new(client_id: CLIENT_ID, client_secret: CLIENT_SECRET)
      begin
        client.check_application_authorization access_token
        return true
      rescue
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
      client = Octokit::Client.new(access_token: oauth_token)
      posts = client.contents(full_repo_name, path: '_posts')
      posts.each do |post|
        post_api_response = client.contents(full_repo_name, path: post.path)
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

    def submit_post(oauth_token, post_markdown, postTitle)
      new_ref = "heads/createPost#{postTitle}"

      client = Octokit::Client.new(access_token: oauth_token)
      master_head_sha = client.ref(full_repo_name, 'heads/master')[:object][:sha]
      sha_base_tree = client.commit(full_repo_name, master_head_sha)[:commit][:tree][:sha]
      ref_sha = client.create_ref(full_repo_name, new_ref, master_head_sha)[:object][:sha]

      blob_sha = client.create_blob(full_repo_name, post_markdown)
      new_tree_sha = client.create_tree(full_repo_name, 
                                        [ { path: "_posts/#{postTitle}.md",
                                            mode: '100644',
                                            type: 'blob',
                                            sha: blob_sha } ],
                                          { base_tree: sha_base_tree })[:sha]
      
      commit_message = "Created post #{postTitle}"
      sha_new_commit = client.create_commit(full_repo_name, commit_message, new_tree_sha, master_head_sha)[:sha]
      client.update_ref(full_repo_name, new_ref, sha_new_commit)
      # TODO: Create pull request for new post
    end

    private
      def full_repo_name
        "#{Rails.configuration.github_org}/#{Rails.configuration.github_repo_name}"
      end
  end
end
