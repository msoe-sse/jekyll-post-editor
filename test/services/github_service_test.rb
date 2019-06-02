require 'test_helper'
require 'mocha/setup'
require 'octokit'
require 'base64'

class GithubServiceTest < ActiveSupport::TestCase
  test 'authenticate should return :unauthorized on failed authentication' do 
    #Arrange
    Octokit::Client.any_instance.expects(:user).raises(Octokit::Unauthorized)

    #Act
    result = GithubService.authenticate('test', 'test')

    #Assert
    assert_equal :unauthorized, result
  end
  
  test 'authenticate should return :not_in_organization on failed authentication' do 
    #Arrange
    user = _create_dummy_api_resource(login: 'test')

    Octokit::Client.any_instance.expects(:user).returns(user)
    Octokit::Client.any_instance.expects(:organization_member?).with('msoe-sse', 'test').returns(false)

    #Act
    result = GithubService.authenticate('test', 'test')

    #Assert
    assert_equal :not_in_organization, result
  end

  test 'authenticate should return a oauth access token on successful authentication' do
    #Arrange
    user = _create_dummy_api_resource(login: 'test')
    authorizations = []

    Octokit::Client.any_instance.expects(:user).returns(user)
    Octokit::Client.any_instance.expects(:authorizations).returns(authorizations)
    Octokit::Client.any_instance.expects(:organization_member?).with('msoe-sse', 'test').returns(true)
    Octokit::Client.any_instance.expects(:create_authorization).returns('access token').at_most_once

    #Act
    result = GithubService.authenticate('test', 'test')

    #Assert
    assert_equal 'access token', result
  end

  test 'authenticate should be able to handle a GitHub user already having a post editor oauth token created' do 
    #Arrange
    user = _create_dummy_api_resource(login: 'test')


    authorizations = [
      {
        :app => {
          :name => 'some app'
        },
        :hashed_token => 'a wrong token'
      },
      {
        :app => {
          :name => 'SSE Post Editor Token'
        },
        :hashed_token => 'premade token'
      }
    ]

    Octokit::Client.any_instance.expects(:user).returns(user)
    Octokit::Client.any_instance.expects(:authorizations).returns(authorizations)
    Octokit::Client.any_instance.expects(:organization_member?).with('msoe-sse', 'test').returns(true)
    Octokit::Client.any_instance.expects(:create_authorization).returns('access token').never

    #Act
    result = GithubService.authenticate('test', 'test')

    #Assert
    assert_equal 'premade token', result
  end

  test 'basic test case for get_all_posts' do 
    #Arrange
    post1 = _create_dummy_api_resource(path: '_posts/post1.md')
    post2 = _create_dummy_api_resource(path: '_posts/post2.md')
    post3 = _create_dummy_api_resource(path: '_posts/post3.md')

    post1_content = _create_dummy_api_resource(content: 'post 1 base 64 content')
    post2_content = _create_dummy_api_resource(content: 'post 2 base 64 content')
    post3_content = _create_dummy_api_resource(content: 'post 3 base 64 content')
    
    post1_model = _create_post_model('post 1', 'Andy Wojciechowski', 'hero 1', 'overlay 1', '#post1', ['announcement', 'info'])
    post2_model = _create_post_model('post 2', 'Grace Fleming', 'hero 2', 'overlay 2', '##post2', ['announcement'])
    post3_model = _create_post_model('post 3', 'Sabrina Stangler', 'hero 3', 'overlay 3', '###post3', ['info'])

    Octokit.expects(:contents).with('msoe-sse/msoe-sse.github.io', path: '_posts').returns([post1, post2, post3])
    Octokit.expects(:contents).with('msoe-sse/msoe-sse.github.io', path: '_posts/post1.md').returns(post1_content)
    Octokit.expects(:contents).with('msoe-sse/msoe-sse.github.io', path: '_posts/post2.md').returns(post2_content)
    Octokit.expects(:contents).with('msoe-sse/msoe-sse.github.io', path: '_posts/post3.md').returns(post3_content)

    Base64.expects(:decode64).with('post 1 base 64 content').returns('post 1 text content')
    Base64.expects(:decode64).with('post 2 base 64 content').returns('post 2 text content')
    Base64.expects(:decode64).with('post 3 base 64 content').returns('post 3 text content')
    
    PostFactory.expects(:create_post).with('post 1 text content').returns(post1_model)
    PostFactory.expects(:create_post).with('post 2 text content').returns(post2_model)
    PostFactory.expects(:create_post).with('post 3 text content').returns(post3_model)

    #Act
    result = GithubService.get_all_posts

    #Assert
    assert_equal [post1_model, post2_model, post3_model], result
  end

  def _create_dummy_api_resource(parameters)
    resource = DummyApiResource.new
    resource.login = parameters[:login]
    resource.path = parameters[:path]
    resource.content = parameters[:content]
    resource
  end

  def _create_post_model(title, author, hero, overlay, contents, tags)
    post_model = Post.new
    post_model.title = title
    post_model.author = author
    post_model.hero = hero
    post_model.overlay = overlay
    post_model
  end

  class DummyApiResource
    attr_accessor :login
    attr_accessor :path
    attr_accessor :content
  end
end