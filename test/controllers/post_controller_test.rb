require 'test_helper'
require 'mocha/setup'

class PostControllerTest < ActionDispatch::IntegrationTest
  test 'should navigate to post/list successfully' do 
    #Act
    get '/post/list'

    #Assert
    assert_response :success
  end

  test 'should navigate to post/edit successfully' do 
    #Act
    get '/post/edit'

    #Assert
    assert_response :success
  end

  test 'should navigate to post/edit successfully with a title parameter' do
    #Arrange
    GithubService.expects(:get_post_by_title).with('title').returns('some object')

    #Act
    get '/post/edit?title=title'

    #Assert
    assert_response :success
  end
end