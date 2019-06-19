require 'test_helper'
require 'mocha/setup'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'the post editor should get index successfully' do 
    # Act
    get '/home/index'

    # Assert
    assert_response :success
  end

  test 'the post editor should get index with root url successfully' do
    # Act
    get '/'

    # Assert
    assert_response :success
  end

  test 'the post editor should redirect back to index with a failed login' do
    # Arrange
    GithubService.expects(:authenticate).with('test', 'test').returns(:unauthorized)

    # Act
    post '/home/login', params: { username: 'test', login: { password: 'test' } }

    # Assert
    assert_redirected_to '/'
    assert_nil session[:access_token]
    assert_equal 'Invalid GitHub username or password', flash[:alert]
  end

  # test 'the post edtior should redirect back to index if a user is not apart of the msoe-sse github organization' do
  #   # Arrange
  #   GithubService.expects(:authenticate).with('test', 'test').returns(:not_in_organization)

  #   # Act
  #   post '/home/login', params: { username: 'test', login: { password: 'test' } }
    
  #   # Assert
  #   assert_redirected_to '/'
  #   assert_nil session[:access_token]
  #   assert_equal 'The GitHub user provided is not apart of the msoe-sse GitHub organization. 
  #                 Please contact the SSE Webmaster for assistance.', flash[:alert]
  # end

  test 'the post editor should redirect to the post list view on successful authentication' do
    # Arrange
    GithubService.expects(:authenticate).with('test', 'test').returns('a token')

    # Act
    post '/home/login', params: { username: 'test', login: { password: 'test' } }

    # Assert
    assert_equal 'a token', session[:access_token]
    assert_redirected_to controller: 'post', action: 'list'
  end
end
