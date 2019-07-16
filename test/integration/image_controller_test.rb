require 'test_helper'

class ImageControllerTest < BaseIntegrationTest
  test 'upload should return a 200 ok response' do 
    # Arrange
    PostImageManager.instance.expects(:add_file).with('dummy file object').once

    # Act
    post '/image/upload', params: { file: 'dummy file object' }

    # Assert
    assert_response :success
  end
end
