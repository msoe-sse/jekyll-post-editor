class GithubControllerTest < BaseIntegrationTest
  test 'the callback url should rredirect back to the index after getting the oauth access token' do
    # Arrange
    GithubService.expects(:get_oauth_access_token).with('session code').returns('access token')

    # Act
    get '/github/callback', params: { code: 'session code' }

    # Assert
    assert_equal 'access token', session[:access_token]
    assert_redirected_to '/'
  end
end
