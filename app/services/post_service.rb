require 'base64'

##
# This module contains operations related to posts on the SSE website
module PostService
  class << self
    ##
    # This method submits a post to GitHub by checking out a new branch for the post,
    # if the branch already doesn't exist Commiting and pushing the markdown and any photos 
    # attached to the post to the branch. And then finally opening a pull request into master 
    # for the new post. The SSE webmaster will be requested for review on the created pull request
    #
    # Params
    # +oauth_token+::a user's oauth access token
    # +post_markdown+:: the markdown contents of a post
    def submit_post(oauth_token, post_markdown, post_title)
      # This ref_name variable represents the branch name
      # for submiting a post. At the end we strip out all of the whitespace in 
      # the post_title to create a valid branch name
      branch_name = "createPost#{post_title.gsub(/\s+/, '')}"
      new_ref = "heads/#{branch_name}"

      pull_request_body = 'This pull request was opened automatically by the jekyll-post-editor.'

      master_head_sha = GithubService.get_master_head_sha(oauth_token)
      sha_base_tree = GithubService.get_base_tree_for_branch(oauth_token, master_head_sha)

      GithubService.create_ref_if_necessary(oauth_token, new_ref)
      
      file_information = [ create_blob_for_post(oauth_token, post_markdown, post_title) ]
      create_image_blobs(oauth_token, post_markdown, file_information)
      new_tree_sha = GithubService.create_new_tree(oauth_token, file_information, sha_base_tree)
      
      GithubService.commit_and_push_to_repo(oauth_token, "Created post #{post_title}", 
                                            new_tree_sha, master_head_sha, new_ref)
      GithubService.create_pull_request(oauth_token, branch_name, 'master', "Created Post #{post_title}", 
                                        pull_request_body, [Rails.configuration.webmaster_github_username])
      
      PostImageManager.instance.clear
    end

    private
      def create_new_filename_for_post(post_title)
        "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-#{post_title.gsub(/\s+/, '')}.md"
      end

      def create_blob_for_post(oauth_token, post_markdown, post_title)
        blob_sha = GithubService.create_text_blob(oauth_token, post_markdown)
        { path: create_new_filename_for_post(post_title), blob_sha: blob_sha }
      end

      def create_image_blobs(oauth_token, post_markdown, current_file_information)
        PostImageManager.instance.uploaders.each do |uploader|
           # This check prevents against images that have been removed from the markdown
          if KramdownService.does_markdown_include_image(uploader.filename, post_markdown)
            # This line uses .file.file since the first .file returns a carrierware object
            base_64_encoded_image = Base64.encode64(File.open(uploader.post_image.file.file, 'rb').read)
            image_blob_sha = GithubService.create_base64_encoded_blob(oauth_token, base_64_encoded_image)
            current_file_information << { path: "assets/img/#{uploader.filename}", blob_sha: image_blob_sha}
          end
        end
      end
  end
end
