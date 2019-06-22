require 'test_helper'
require 'mocha/setup'

class PostControllerTest < ActionDispatch::IntegrationTest
  test 'an authenticated user should be able to navigate to post/list successfully' do 
    # Arramge
    setup_session('access token', true)

    post1 = create_post_model(title: 'title1', author: 'author1', hero: 'hero1', 
                              overlay: 'overlay1', contents: 'contents1', tags: ['tag1', 'tag2'])
    post2 = create_post_model(title: 'title2', author: 'author2', hero: 'hero2', 
                              overlay: 'overlay2', contents: 'contents2', tags: ['tag1', 'tag2'])
    GithubService.expects(:get_all_posts).with('access token').returns([post1, post2])

    # Act
    get '/post/list'

    # Assert
    assert_response :success
  end

  test 'an authenticated user should be able to navigate to / successfully' do 
    # Arramge
    setup_session('access token', true)

    post1 = create_post_model(title: 'title1', author: 'author1', hero: 'hero1', 
                              overlay: 'overlay1', contents: 'contents1', tags: ['tag1', 'tag2'])
    post2 = create_post_model(title: 'title2', author: 'author2', hero: 'hero2', 
                              overlay: 'overlay2', contents: 'contents2', tags: ['tag1', 'tag2'])
    GithubService.expects(:get_all_posts).with('access token').returns([post1, post2])

    # Act
    get '/'

    # Assert
    assert_response :success
  end

  test 'an unauthenticated user should be redirected to GitHub when navigating to post/list' do
    # Act
    get '/post/list'

    # Assert
    assert_redirected_to 'https://github.com/login/oauth/authorize?client_id=github client id&scope=write%3Aorg'
  end

  test 'an unauthenticated user should be redirected to GitHub when navigating to /' do
    # Act
    get '/'

    # Assert
    assert_redirected_to 'https://github.com/login/oauth/authorize?client_id=github client id&scope=write%3Aorg'
  end

  test 'an authenticated user should be able to navigate to post/edit successfully' do 
    # Arrange
    setup_session('access token', true)

    # Act
    get '/post/edit'

    # Assert
    assert_response :success
  end

  test 'an unauthenticated user should be redirected to GitHub when navigating to post/edit' do
    # Act
    get '/post/edit'

    # Assert
    assert_redirected_to 'https://github.com/login/oauth/authorize?client_id=github client id&scope=write%3Aorg'
  end

  test 'an authenticated user should be able to navigate to post/edit successfully with a title parameter' do
    # Arrange
    setup_session('access token', true)

    post = create_post_model(title: 'title', author: 'author', hero: 'hero', 
                              overlay: 'overlay', contents: 'contents',  tags: ['tag1', 'tag2'])
    GithubService.expects(:get_post_by_title).with('access token', 'title').returns(post)

    # Act
    get '/post/edit?title=title'

    # Assert
    assert_response :success
  end

  private
    def create_post_model(parameters)
      post_model = Post.new
      post_model.title = parameters[:title]
      post_model.author = parameters[:author]
      post_model.hero = parameters[:hero]
      post_model.overlay = parameters[:overlay]
      post_model.contents = parameters[:contents]
      post_model.tags = parameters[:tags]
      post_model
    end

    def setup_session(access_token, is_valid_token)
      session = { access_token: access_token }
      PostController.any_instance.expects(:session).at_least_once.returns(session)
      GithubService.expects(:check_access_token).with(access_token).returns(is_valid_token)
    end
end
