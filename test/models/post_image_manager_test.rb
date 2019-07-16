require 'test_helper'

class PostImageManagerTest < ActiveSupport::TestCase
  test 'add_file should create a new PostImageUploader and cache the file' do 
    # Arrange
    PostImageUploader.any_instance.expects(:cache!).with('dummy file object').once

    # Act
    PostImageManager.instance.add_file('dummy file object')

    # Assert
    assert_equal 1, PostImageManager.instance.uploaders.length
    assert PostImageManager.instance.uploaders.first.is_a?(PostImageUploader)
  end

  test 'clear should clear all PostImageUploader instances from the manager' do 
    # Arrange
    PostImageUploader.any_instance.expects(:cache!).with('dummy file object').once

    # Act
    PostImageManager.instance.add_file('dummy file object')
    PostImageManager.instance.clear

    # Assert
    assert_equal 0, PostImageManager.instance.uploaders.length
  end
end
