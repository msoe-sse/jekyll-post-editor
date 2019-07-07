##
# This class tests the custom rails error handlers
class ErrorTest < BaseIntegrationTest
  test 'a controller should redirect to /RateLimitError.html when a Octokit::TooManyRequests error is raised' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    GithubService.expects(:submit_post).with('access token', 'post text', 'title').raises(Octokit::TooManyRequests)
    KramdownService.expects(:create_jekyll_post_text)
                   .with('# hello', 'author', 'title', 'tags', 'red').returns('post text')
            
    # Act
    post '/post/submit', params: { title: 'title', author: 'author', 
                                   markdownArea: '# hello', tags: 'tags', overlay: 'red' }
            
    # Assert
    assert_redirected_to '/RateLimitError.html'
  end
end
