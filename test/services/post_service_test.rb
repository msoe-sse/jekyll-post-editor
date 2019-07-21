require 'test_helper'
require 'mocha/setup'

class PostServiceTest < ActiveSupport::TestCase
  test 'submit_post should commit and push a new post up to the SSE website Github repo' do 
    # Arrange
    GithubService.expects(:get_master_head_sha).with('my token').returns('master head sha')
    GithubService.expects(:get_base_tree_for_branch).with('my token', 'master head sha').returns('master tree sha')
    GithubService.expects(:create_ref).with('my token', 'heads/createPostTestPost').once
    GithubService.expects(:create_new_tree)
                 .with('my token', "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-TestPost.md", '# hello', 'master tree sha')
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

    # Act
    PostService.submit_post('my token', '# hello', 'TestPost')

    # No Assert - taken care of with mocha mock setups
  end

  test 'submit_post should create a valid branch name if the post title has whitespace' do 
    # Arrange
    GithubService.expects(:get_master_head_sha).with('my token').returns('master head sha')
    GithubService.expects(:get_base_tree_for_branch).with('my token', 'master head sha').returns('master tree sha')
    GithubService.expects(:create_ref).with('my token', 'heads/createPostTestPost').once
    GithubService.expects(:create_new_tree)
                 .with('my token', "_posts/#{DateTime.now.strftime('%Y-%m-%d')}-TestPost.md", '# hello', 'master tree sha')
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
    
    # Act
    PostService.submit_post('my token', '# hello', 'Test Post')
    
    # No Assert - taken care of with mocha mock setups
  end
end
