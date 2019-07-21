##
# This module contains operations related to posts on the SSE website
module PostService
  class << self
    ##
    # This method submits a post to GitHub by checking out a new branch for the post.
    # Commiting and pushing the markdown to the branch. And then finally opening 
    # a pull request into master for the new post. The SSE webmaster will be requested
    # for review on the created pull request
    #
    # Params
    # +oauth_token+::a user's oauth access token
    # +post_markdown+:: the markdown contents of a post
    # +post_title+:: the title of the new post to be submited
    def submit_post(oauth_token, post_markdown, post_title)
      # This new_ref variable represents the new branch we are creating
      # for submiting a post. At the end we strip out all of the whitespace in 
      # the post_title to create a valid branch name
      branch_name = "createPost#{post_title.gsub(/\s+/, '')}"
      new_ref = "heads/#{branch_name}"

      pull_request_body = 'This pull request was opened automatically by the jekyll-post-editor.'

      master_head_sha = GithubService.get_master_head_sha(oauth_token)
      sha_base_tree = GithubService.get_base_tree_for_branch(oauth_token, master_head_sha)

      GithubService.create_ref(oauth_token, new_ref)

      new_tree_sha = GithubService.create_new_tree(oauth_token, create_new_filename_for_post(post_title), 
                                                   post_markdown, sha_base_tree)
      
      GithubService.commit_and_push_to_repo(oauth_token, "Created post #{post_title}", 
                                            new_tree_sha, master_head_sha, new_ref)
      GithubService.create_pull_request(oauth_token, branch_name, 'master', "Created Post #{post_title}", 
                                        pull_request_body, [Rails.configuration.webmaster_github_username])
    end

    private
      def create_new_filename_for_post(post_title)
        "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-#{post_title.gsub(/\s+/, '')}.md"
      end
  end
end
