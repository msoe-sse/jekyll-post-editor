require 'test_helper'
require 'mocha/setup'

class PostControllerTest < ActionDispatch::IntegrationTest
  test 'should navigate to post/list successfully' do 
    #Act
    get '/post/list'

    #Assert
    assert_response :success
  end
end