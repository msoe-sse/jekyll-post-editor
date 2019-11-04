require 'base64'
require 'net/http'

##
# This module contains operations related to posts on the SSE website
module PostService
  class << self
    PULL_REQUEST_BODY = 'This pull request was opened automatically by the jekyll-post-editor.'

    ##
    # This method submits a new post to GitHub by checking out a new branch for the post,
    # if the branch already doesn't exist. Commiting and pushing the markdown and any photos 
    # attached to the post to the branch. And then finally opening a pull request into master 
    # for the new post. The SSE webmaster will be requested for review on the created pull request
    #
    # Params
    # +oauth_token+::a user's oauth access token
    # +post_markdown+:: the markdown contents of a post
    def create_post(oauth_token, post_markdown, post_title)
      # This ref_name variable represents the branch name
      # for creating a post. At the end we strip out all of the whitespace in 
      # the post_title to create a valid branch name
      branch_name = "createPost#{post_title.gsub(/\s+/, '')}"
      ref_name = "heads/#{branch_name}"

      master_head_sha = GithubService.get_master_head_sha(oauth_token)
      sha_base_tree = GithubService.get_base_tree_for_branch(oauth_token, master_head_sha)

      GithubService.create_ref_if_necessary(oauth_token, ref_name, master_head_sha)
      
      new_post_path = create_new_filepath_for_post(post_title)
      new_tree_sha = create_new_tree(oauth_token, post_markdown, post_title, new_post_path, sha_base_tree)
      
      GithubService.commit_and_push_to_repo(oauth_token, "Created post #{post_title}", 
                                            new_tree_sha, master_head_sha, ref_name)
      GithubService.create_pull_request(oauth_token, branch_name, 'master', "Created Post #{post_title}", 
                                       PULL_REQUEST_BODY, [Rails.configuration.webmaster_github_username])
      
      PostImageManager.instance.clear
    end

    ##
    # This method submits changes to an existing post to GitHub by checking out a new branch for the post,
    # if the branch already doesn't exist. Commiting and pushing the markdown changes and any added photos
    # for the existing post to the branch. And the finally opening a pull request into master for the new post.
    # The SSE webmaster will be requested for review on the created pull request
    #
    # Params
    # +oauth_token+::a user's oauth access token
    # +post_markdown+::the modified markdown to submit
    # +post_title+::the title for the existing post
    # +existing_post_file_path+::the file path to the existing post on GitHub
    def edit_post(oauth_token, post_markdown, post_title, existing_post_file_path)
      # This ref_name variable represents the branch name
      # for editing a post. At the end we strip out all of the whitespace in 
      # the post_title to create a valid branch name
      branch_name = "editPost#{post_title.gsub(/\s+/, '')}"
      ref_name = "heads/#{branch_name}"

      master_head_sha = GithubService.get_master_head_sha(oauth_token)
      sha_base_tree = GithubService.get_base_tree_for_branch(oauth_token, master_head_sha)

      GithubService.create_ref_if_necessary(oauth_token, ref_name, master_head_sha)
      new_tree_sha = create_new_tree(oauth_token, post_markdown, post_title, existing_post_file_path, sha_base_tree)

      GithubService.commit_and_push_to_repo(oauth_token, "Edited post #{post_title}", 
                                            new_tree_sha, master_head_sha, ref_name)
      GithubService.create_pull_request(oauth_token, branch_name, 'master', "Edited Post #{post_title}", 
                                        Rails.configuration.pull_request_body, 
                                        [Rails.configuration.webmaster_github_username])
      
      PostImageManager.instance.clear
    end

    ##
    # This method validates the hero for a post when the hero is a URL. In that case we make a request to the URL
    # to see if the URL is an image or not. The URL must be an image in order for the URL to be valid
    #
    # Params
    # +url+::a url representing the hero of a post
    def is_valid_hero(url)
      url = URI.parse(url)
      Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        return http.head(url.request_uri)['Content-Type'].start_with? 'image'
      end
    end

    
    private
      def create_new_filepath_for_post(post_title)
        "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-#{post_title.gsub(/\s+/, '')}.md"
      end

      def create_blob_for_post(oauth_token, post_markdown, post_title, post_file_path)
        blob_sha = GithubService.create_text_blob(oauth_token, post_markdown)
        { path: post_file_path, blob_sha: blob_sha }
      end

      def create_image_blobs(oauth_token, post_markdown, current_file_information)
        PostImageManager.instance.uploaders.each do |uploader|
          # This check prevents against images that have been removed from the markdown
          markdown_file_name = KramdownService.get_image_filename_from_markdown(uploader.filename, post_markdown)
          if markdown_file_name
            # This line uses .file.file since the first .file returns a carrierware object
            File.open(uploader.post_image.file.file, 'rb') do |file|
              base_64_encoded_image = Base64.encode64(file.read)
              image_blob_sha = GithubService.create_base64_encoded_blob(oauth_token, base_64_encoded_image)
              current_file_information << { path: "assets/img/#{markdown_file_name}", blob_sha: image_blob_sha }
            end
          end
        end
      end

      def create_new_tree(oauth_token, post_markdown, post_title, post_file_path, sha_base_tree)
        file_information = [ create_blob_for_post(oauth_token, post_markdown, post_title, post_file_path) ]
        create_image_blobs(oauth_token, post_markdown, file_information)
        GithubService.create_new_tree_with_blobs(oauth_token, file_information, sha_base_tree)
      end
  end
end
