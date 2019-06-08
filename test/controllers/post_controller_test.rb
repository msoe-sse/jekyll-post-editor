require 'test_helper'
require 'mocha/setup'

class PostControllerTest < ActionDispatch::IntegrationTest
  test 'the post editor should navigate to post/list successfully' do 
    post1 = _create_post_model('title1', 'author1', 'hero1', 'overlay1', 'contents1', ['tag1', 'tag2'])
    post2 = _create_post_model('title2', 'author2', 'hero2', 'overlay2', 'contents2', ['tag1', 'tag2'])
    GithubService.expects(:get_all_posts).with(nil).returns([post1, post2])

    #Act
    get '/post/list'

    #Assert
    assert_response :success
  end

  test 'the post editor should navigate to post/edit successfully' do 
    #Act
    get '/post/edit'

    #Assert
    assert_response :success
  end

  test 'the post editor should navigate to post/edit successfully with a title parameter' do
    #Arrange
    post = _create_post_model('title', 'author', 'hero', 'overlay', 'contents', ['tag1', 'tag2'])
    GithubService.expects(:get_post_by_title).with(nil, 'title').returns(post)

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