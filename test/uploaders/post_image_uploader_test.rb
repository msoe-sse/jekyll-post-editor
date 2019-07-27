require 'test_helper'

class PostImageUploaderTest < ActiveSupport::TestCase
  test 'PostImageUploader should only support images' do 
    # Arrange
    uploader = PostImageUploader.new

    # Act
    result = uploader.extension_whitelist

    # Assert
    assert_equal ['jpg', 'jpeg', 'gif', 'png'], result
  end
end
