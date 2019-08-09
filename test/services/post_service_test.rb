require 'test_helper'
require 'mocha/setup'

class PostServiceTest < ActiveSupport::TestCase
  test 'submit_post should commit and push a new post up to the SSE website Github repo' do 
    # Arrange
    post_file_path = "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-TestPost.md"

    GithubService.expects(:get_master_head_sha).with('my token').returns('master head sha')
    GithubService.expects(:get_base_tree_for_branch).with('my token', 'master head sha').returns('master tree sha')
    GithubService.expects(:create_ref_if_necessary)
                 .with('my token', 'heads/createPostTestPost', 'master head sha').once
    GithubService.expects(:create_text_blob).with('my token', '# hello').returns('post blob sha')
    GithubService.expects(:create_new_tree_with_blobs)
                 .with('my token', [ create_file_info_hash(post_file_path, 'post blob sha')], 'master tree sha')
                 .returns('new tree sha')
    GithubService.expects(:commit_and_push_to_repo)
                 .with('my token', 'Created post TestPost', 'new tree sha', 
                       'master head sha', 'heads/createPostTestPost').once
    GithubService.expects(:create_pull_request)
                 .with('my token', 
                       'createPostTestPost', 
                       'master', 
                       'Created Post TestPost', 
                       'This pull request was opened automatically by the jekyll-post-editor.', 
                       ['msoe-sse-webmaster']).once

    PostImageManager.instance.expects(:clear).once

    # Act
    PostService.submit_post('my token', '# hello', 'TestPost')

    # No Assert - taken care of with mocha mock setups
  end

  test 'submit_post should create a valid branch name if the post title has whitespace' do 
    # Arrange
    post_file_path = "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-TestPost.md"

    GithubService.expects(:get_master_head_sha).with('my token').returns('master head sha')
    GithubService.expects(:get_base_tree_for_branch).with('my token', 'master head sha').returns('master tree sha')
    GithubService.expects(:create_ref_if_necessary)
                 .with('my token', 'heads/createPostTestPost', 'master head sha').once
    GithubService.expects(:create_text_blob).with('my token', '# hello').returns('post blob sha')
    GithubService.expects(:create_new_tree_with_blobs)
                 .with('my token', [ create_file_info_hash(post_file_path, 'post blob sha')], 'master tree sha')
                 .returns('new tree sha')
    GithubService.expects(:commit_and_push_to_repo)
                 .with('my token', 'Created post Test Post', 'new tree sha', 
                       'master head sha', 'heads/createPostTestPost').once
    GithubService.expects(:create_pull_request)
                 .with('my token', 
                       'createPostTestPost', 
                       'master', 
                       'Created Post Test Post', 
                       'This pull request was opened automatically by the jekyll-post-editor.', 
                       ['msoe-sse-webmaster']).once

    PostImageManager.instance.expects(:clear).once

    # Act
    PostService.submit_post('my token', '# hello', 'Test Post')
    
    # No Assert - taken care of with mocha mock setups
  end

  test 'submit_post should upload any images if any exist in the PostImageManager' do 
    # Arrange
    post_file_path = "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-TestPost.md"
    test_markdown = "# hello\r\n![My File.jpg](/assets/img/My Image 1.jpg)"

    mock_uploader1 = create_mock_uploader('post_image-My_Image_1.jpg', 'cache 1', 
                                           create_mock_carrierware_file('C:\post_image-My Image 1.jpg'))
    post_image_uploader1 = create_post_image_uploader('My_Image_1.jpg', mock_uploader1)

    mock_uploader2 = create_mock_uploader('post_image-My_Image_2.jpg', 'cache 2', 
                                           create_mock_carrierware_file('C:\post_image-My Image 2.jpg'))
    post_image_uploader2 = create_post_image_uploader('My_Image_2.jpg', mock_uploader2)
    
    KramdownService.expects(:get_image_filename_from_markdown)
                   .with('My_Image_1.jpg', test_markdown).returns('My Image 1.jpg')
    KramdownService.expects(:get_image_filename_from_markdown)
                   .with('My_Image_2.jpg', test_markdown).returns(nil)
    
    image_blob_sha1 = mock_image_blob_and_return_sha(post_image_uploader1)
    PostImageManager.instance.expects(:uploaders).returns([ post_image_uploader1, post_image_uploader2 ])

    GithubService.expects(:get_master_head_sha).with('my token').returns('master head sha')
    GithubService.expects(:get_base_tree_for_branch).with('my token', 'master head sha').returns('master tree sha')
    GithubService.expects(:create_ref_if_necessary)
                 .with('my token', 'heads/createPostTestPost', 'master head sha').once
    GithubService.expects(:create_text_blob).with('my token', test_markdown).returns('post blob sha')
    GithubService.expects(:create_new_tree_with_blobs)
                 .with('my token', [ create_file_info_hash(post_file_path, 'post blob sha'), 
                                     create_file_info_hash('assets/img/My Image 1.jpg', image_blob_sha1)], 
                        'master tree sha')
                 .returns('new tree sha')
    GithubService.expects(:commit_and_push_to_repo)
                 .with('my token', 'Created post Test Post', 'new tree sha', 
                       'master head sha', 'heads/createPostTestPost').once
    GithubService.expects(:create_pull_request)
                 .with('my token', 
                       'createPostTestPost', 
                       'master', 
                       'Created Post Test Post', 
                       'This pull request was opened automatically by the jekyll-post-editor.', 
                       ['msoe-sse-webmaster']).once

    PostImageManager.instance.expects(:clear).once

    # Act
    PostService.submit_post('my token', test_markdown, 'Test Post')

    # No Assert - taken care of with mocha mock setups
  end

  private
    def create_file_info_hash(file_path, blob_sha)
      { path: file_path, blob_sha: blob_sha }
    end

    def mock_image_blob_and_return_sha(mock_uploader)
      mock_ruby_file = create_mock_ruby_file(mock_uploader.filename)
      File.expects(:open).with(mock_uploader.post_image.file.file, 'rb').returns(mock_ruby_file)
      Base64.expects(:encode64).with("File Contents for #{mock_uploader.filename}")
            .returns("base 64 for #{mock_uploader.filename}")
      
      sha_to_return = "blob sha for #{mock_uploader.filename}"
      GithubService.expects(:create_base64_encoded_blob)
                   .with('my token', "base 64 for #{mock_uploader.filename}")
                   .returns(sha_to_return)
      
      sha_to_return
    end
end
