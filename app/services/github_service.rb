require 'octokit'
require 'base64'
require 'date'
require 'cgi'

##
# This module contains all operations involving interacting with the GitHub API
module GithubService
  class << self
    CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
    CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

    ##
    # This method get the authorization url which authorizes the post editor app
    # to use a user's GitHub account. The scopes public_repo is used so that we're able
    # to make changes to the msoe-sse/mseo-sse.github.io repository which requires
    # access to a user's public repositories. Also, the scope read:org is used so that
    # we can read public and private org membership
    def get_authorization_url
      client = Octokit::Client.new
      client.authorize_url(CLIENT_ID, scope: 'public_repo read:org')
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
    # Checks to see if a user authenticated with an oauth access token is a member
    # of the SSE GitHub organization or not
    #
    # Params
    # +access_token+:: a GitHub oauth access token
    def check_sse_github_org_membership(access_token)
      client = Octokit::Client.new(access_token: access_token)
      client.organization_member?(Rails.configuration.github_org, client.user[:login])
    end

    ##
    # This method fetches all the markdown contents of all the posts on the SSE website
    # that a user has written and returns a list of models representing a Post. A user is determined
    # to have written a post if the oldest commit for a post matches the current authenticated GitHub
    # user.
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    def get_all_posts(oauth_token)
      result = []
      client = Octokit::Client.new(access_token: oauth_token)
      posts = client.contents(full_repo_name, path: '_posts')
      posts.each do |post|
        oldest_commit = get_oldest_commit_for_file(client, post.path)
        username = client.user[:login]
        if username == oldest_commit[:author][:login]
          post_api_response = client.contents(full_repo_name, path: post.path)
          result << create_post_from_api_response(post_api_response, nil) 
        end
      end
      result
    end

    ##
    # This method fetches all of the posts that a user has written but have not been merged into master yet.
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    def get_all_posts_in_pr_for_user(oauth_token)
      result = []
      client = Octokit::Client.new(access_token: oauth_token)
      pull_requests_for_user = get_open_post_editor_pull_requests(oauth_token)
      
      pull_requests_for_user.each do | pull_request |
        pull_request_files = client.pull_request_files(full_repo_name, pull_request[:number])

        pull_request_files.each do | pull_request_file |
          if pull_request_file[:filename].ends_with?('.md')
            contents_url_params = CGI.parse(pull_request_file[:contents_url])

            # The CGI.parse method returns a hash with the key being the URL and the value being an array of
            # URI parameters so in order to get the ref we need to grab the first value in the hash and the first
            # URI parameter in the first hash value
            ref = contents_url_params.values.first.first
            post = client.contents(full_repo_name, path: pull_request_file[:filename], ref: ref)

            result << create_post_from_api_response(post, ref)
          end
        end
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
    # +ref+:: The ref indicating which branch the post is on in GitHub
    def get_post_by_title(oauth_token, title, ref)
      return get_all_posts_in_pr_for_user(oauth_token).find { |x| x.title == title } if ref
      get_all_posts(oauth_token).find { |x| x.title == title }
    end

    ##
    # This method gets the sha of the commit at the head of master in the SSE website repo
    #
    # Params
    # +oauth_token+::a user's oauth access token
    def get_master_head_sha(oauth_token)
      client = Octokit::Client.new(access_token: oauth_token)
      client.ref(full_repo_name, 'heads/master')[:object][:sha]
    end

    ##
    # This method gets the sha of the base tree for a given branch in the SSE website repo
    #
    # Params
    # +oauth_token+::a user's oauth access token
    # +head_sha+::the sha of the head of a certain branch
    def get_base_tree_for_branch(oauth_token, head_sha)
      client = Octokit::Client.new(access_token: oauth_token)
      client.commit(full_repo_name, head_sha)[:commit][:tree][:sha]
    end

    ##
    # This method create a new blob in the SSE website repo with text content
    #
    # Params
    # +oauth_token+::a user's oauth access token
    # +text+::the text content to create a blob for
    def create_text_blob(oauth_token, text)
      client = Octokit::Client.new(access_token: oauth_token)
      client.create_blob(full_repo_name, text)
    end

    ##
    # This method creates a new blob in the SSE website repo with base 64 encoded content
    #
    # Params
    # +oauth_token+::a user's oauth access token
    # +content+::the base 64 encoded content to create a blob for
    def create_base64_encoded_blob(oauth_token, content)
      client = Octokit::Client.new(access_token: oauth_token)
      client.create_blob(full_repo_name, content, 'base64')
    end

    ##
    # This method creates a new tree in the SSE website repo and returns the tree's sha.
    # The method assumes that the paths passed into the method have corresponding blobs
    # created for the files
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    # +file_information+::an array of hashes containing the file path and the blob sha for a file
    # +sha_base_tree+::the sha of the base tree
    def create_new_tree_with_blobs(oauth_token, file_information, sha_base_tree)
      client = Octokit::Client.new(access_token: oauth_token)
      blob_information = []
      file_information.each do |file|
        # This mode property on this hash represents the file mode for a GitHub tree. 
        # The mode is 100644 for a file blob. See https://developer.github.com/v3/git/trees/ for more information
        blob_information << { path: file[:path],
                              mode: '100644',
                              type: 'blob',
                              sha: file[:blob_sha] }
      end
      client.create_tree(full_repo_name, blob_information, base_tree: sha_base_tree)[:sha]
    end

    ##
    # This method commits and pushes a tree to the SSE website repo
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    # +commit_message+::the message for the new commit
    # +tree_sha+::the sha of the tree to commit
    # +head_sha+::the sha of the head to commit from
    def commit_and_push_to_repo(oauth_token, commit_message, 
                                tree_sha, head_sha, ref_name)
      client = Octokit::Client.new(access_token: oauth_token)
      sha_new_commit = client.create_commit(full_repo_name, commit_message, tree_sha, head_sha)[:sha]
      client.update_ref(full_repo_name, ref_name, sha_new_commit)
    end

    ##
    # This method creates a pull request for a branch in the SSE website repo
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    # +source_branch+::the source branch for the PR
    # +base_branch+::the base branch for the PR
    # +pr_title+::the title for the PR
    # +pr_body+::the body for the PR
    # +reviewers+::an array of pull request reviewers for the PR
    def create_pull_request(oauth_token, source_branch, base_branch, pr_title, pr_body, reviewers)
      client = Octokit::Client.new(access_token: oauth_token)
      pull_number = client.create_pull_request(full_repo_name, base_branch, source_branch, pr_title, pr_body)[:number]
      client.request_pull_request_review(full_repo_name, pull_number, reviewers: reviewers)
    end

    ##
    # This method will create a branch in the SSE website repo
    # if it already doesn't exist
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    # +ref_name+:: the name of the branch to create if necessary
    # +master_head_sha+:: the sha representing the head of master
    def create_ref_if_necessary(oauth_token, ref_name, master_head_sha)
      client = Octokit::Client.new(access_token: oauth_token)
      client.ref(full_repo_name, ref_name)
      rescue Octokit::NotFound
        client.create_ref(full_repo_name, ref_name, master_head_sha)
    end

    ##
    # This method will fetch a GitHub's ref name given it's sha identifier.
    # It will also strip off the starting refs portion of the name
    #
    # Params:
    # +oauth_token+::a user's oauth access token
    # +ref_sha+:: the sha of the ref to fetch
    def get_ref_name_by_sha(oauth_token, ref_sha)
      client = Octokit::Client.new(access_token: oauth_token)
      ref_response = client.refs(full_repo_name).find { |x| x[:object][:sha] == ref_sha }
      ref_response[:ref].match(/refs\/(.*)/).captures.first
    end

    private
      def full_repo_name
        "#{Rails.configuration.github_org}/#{Rails.configuration.github_repo_name}"
      end

      def get_oldest_commit_for_file(client, path)
        commits = client.commits(full_repo_name, path: path)
        min_date = commits.map { |x| x[:commit][:committer][:date] }.min
        commits.find { |x| x[:commit][:committer][:date] == min_date }
      end

      def create_post_from_api_response(post, ref)
        # Base64.decode64 will convert our string into a ASCII string
        # calling force_encoding('UTF-8') will fix that problem
        text_contents = Base64.decode64(post.content).force_encoding('UTF-8')
        PostFactory.create_post(text_contents, post.path, ref)
      end

      def get_open_post_editor_pull_requests(oauth_token)
        client = Octokit::Client.new(access_token: oauth_token)
        open_pull_requests = client.pull_requests(full_repo_name, state: 'open')
        open_pull_requests.select { |x| x[:user][:login] == client.user[:login] && 
                                        x[:body] == Rails.configuration.pull_request_body}
      end
  end
end
