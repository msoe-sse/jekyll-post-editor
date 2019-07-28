require 'test_helper'

class PostHelperTest < ActiveSupport::TestCase
  include PostHelper

  test 'get_post_submission_url should not add a path url parameter given a nil path' do 
    # Act
    result = get_post_submission_url(nil)

    # Assert
    assert_equal '/post/submit', result
  end

  test 'get_post_submission_url should add a path url parameter given a path as a string' do 
    # Arrange
    result = get_post_submission_url('my-path')

    # Assert
    assert_equal '/post/submit?path=my-path', result
  end

  test 'get_selected_overlay should return Red if the overlay passed in matches red in any case' do 
    # Arrange
    result = get_selected_overlay('REd')

    # Assert
    assert_equal 'Red', result
  end

  test 'get_selected_overlay should return Blue if the overlay passed in matches blue in any case' do 
    # Arrange
    result = get_selected_overlay('BLUe')

    # Assert
    assert_equal 'Blue', result
  end

  test 'get_selected_overlay should return Green if the overlay passed in matches green in any case' do 
    # Arrange
    result = get_selected_overlay('GREen')

    # Assert
    assert_equal 'Green', result
  end

  test 'get_selected_overlay should return nil if the overlay does not match red, blue, or green' do 
    # Arrange
    result = get_selected_overlay('Aqua Marine')

    # Assert
    assert_nil result
  end
end
