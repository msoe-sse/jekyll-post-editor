require 'test_helper'
require 'mocha/setup'

class PostControllerTest < ActionDispatch::IntegrationTest
  test 'an authenticated user should be able to navigate to post/list successfully' do 
    #Arramge
    setup_session('access token', true)

    post1 = create_post_model('title1', 'author1', 'hero1', 'overlay1', 'contents1', ['tag1', 'tag2'])
    post2 = create_post_model('title2', 'author2', 'hero2', 'overlay2', 'contents2', ['tag1', 'tag2'])
    GithubService.expects(:get_all_posts).with('access token').returns([post1, post2])

    #Act
    get '/post/list'

    #Assert
    assert_response :success
  end

  test 'an authenticated user should be able to navigate to post/edit successfully' do 
    #Arrange
    setup_session('access token', true)

    #Act
    get '/post/edit'

    #Assert
    assert_response :success
  end

  test 'the post editor should navigate to post/edit successfully with a title parameter' do
    #Arrange
    setup_session('access token', true)

    post = create_post_model('title', 'author', 'hero', 'overlay', 'contents', ['tag1', 'tag2'])
    GithubService.expects(:get_post_by_title).with('access token', 'title').returns(post)

    #Act
    get '/post/edit?title=title'

    #Assert
    assert_response :success
  end

  private
  def create_post_model(title, author, hero, overlay, contents, tags)
    post_model = Post.new
    post_model.title = title
    post_model.author = author
    post_model.hero = hero
    post_model.overlay = overlay
    post_model.contents = contents
    post_model.tags = tags
    post_model
  end

  def setup_session(access_token, is_valid_token)
    session = {:access_token => access_token}
    PostController.any_instance.expects(:session).at_least_once.returns(session)
    GithubService.expects(:check_access_token).with(access_token).returns(is_valid_token)
  end
end