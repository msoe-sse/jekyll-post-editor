require 'test_helper'
require 'mocha/setup'

class PostImageManagerTest < ActiveSupport::TestCase
  test 'add_file should create a new PostImageUploader and cache the file' do 
    # Arrange
    setup_clear_mocks
    PostImageManager.instance.clear
    mock_file = create_mock_action_dispatch_file('my file.jpg')
    PostImageUploader.any_instance.expects(:cache!).with(mock_file).once

    # Act
    PostImageManager.instance.add_file(mock_file)

    # Assert
    assert_equal 1, PostImageManager.instance.uploaders.length
    assert PostImageManager.instance.uploaders.first.is_a?(PostImageUploader)
  end

  test 'add_file should remove any previous uploaders that have the same filename as the file being added' do 
    # Arrange
    setup_clear_mocks
    PostImageManager.instance.clear
    mock_file = create_mock_action_dispatch_file('my file.jpg')
    PostImageUploader.any_instance.expects(:cache!).with(mock_file).twice
    PostImageUploader.any_instance.expects(:filename).returns('my file.jpg').at_least_once

    # Act
    PostImageManager.instance.add_file(mock_file)
    PostImageManager.instance.add_file(mock_file)

    # Assert
    assert_equal 1, PostImageManager.instance.uploaders.length
    assert PostImageManager.instance.uploaders.first.is_a?(PostImageUploader)
  end

  test 'clear should clear all PostImageUploader instances from the manager' do 
    # Arrange
    setup_clear_mocks
    PostImageManager.instance.clear
    mock_file = create_mock_action_dispatch_file('my file.jpg')

    PostImageUploader.any_instance.expects(:cache!).with(mock_file).once

    # Act
    PostImageManager.instance.add_file(mock_file)
    PostImageManager.instance.clear

    # Assert
    assert_equal 0, PostImageManager.instance.uploaders.length
  end

  private
    def setup_clear_mocks
      mock_uploader = create_mock_uploader('preview_my file.jpg', 'my cache/preview_my file.jpg', nil)
      preview_uploader = create_preview_uploader('my file', mock_uploader)

      PostImageUploader.any_instance.expects(:preview).returns(preview_uploader).at_least(0)
      PostImageUploader.any_instance.expects(:remove!).at_least(0)
      Dir.expects(:delete).at_least(0)
    end
end
