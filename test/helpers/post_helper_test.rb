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
end
