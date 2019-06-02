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
    post = _create_post_model('title', 'author', 'hero', 'overlay', 'contents', ['tag1', 'tag2'])
    GithubService.expects(:get_post_by_title).with('title').returns(post)

    #Act
    get '/post/edit?title=title'

    #Assert
    assert_response :success
  end

  def _create_post_model(title, author, hero, overlay, contents, tags)
    post_model = Post.new
    post_model.title = title
    post_model.author = author
    post_model.hero = hero
    post_model.overlay = overlay
    post_model.contents = contents
    post_model.tags = tags
    post_model
  end
end