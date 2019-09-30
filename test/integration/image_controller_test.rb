require 'test_helper'

class ImageControllerTest < BaseIntegrationTest
  test 'upload should return a 200 ok response' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostImageManager.instance.expects(:add_file).with('dummy file object').once

    # Act
    post '/image/upload', params: { file: 'dummy file object' }

    # Assert
    assert_response :success
  end
end
