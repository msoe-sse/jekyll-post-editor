require 'test_helper'
require 'mocha/setup'

class PostControllerTest < ActionDispatch::IntegrationTest
  test 'the post editor should navigate to post/list successfully' do 
    post1 = _create_post_model(title: 'title1', author: 'author1', hero: 'hero1', 
                               overlay: 'overlay1', contents: 'contents1', tags: ['tag1', 'tag2'])
    post2 = _create_post_model(title: 'title2', author: 'author2', hero: 'hero2', 
                               overlay: 'overlay2', contents: 'contents2', tags: ['tag1', 'tag2'])
    GithubService.expects(:get_all_posts).with(nil).returns([post1, post2])

    # Act
    get '/post/list'

    # Assert
    assert_response :success
  end

  test 'the post editor should navigate to post/edit successfully' do 
    # Act
    get '/post/edit'

    # Assert
    assert_response :success
  end

  test 'the post editor should navigate to post/edit successfully with a title parameter' do
    # Arrange
    post = _create_post_model(title: 'title', author: 'author', hero: 'hero', 
                              overlay: 'overlay', contents: 'contents',  tags: ['tag1', 'tag2'])
    GithubService.expects(:get_post_by_title).with(nil, 'title').returns(post)

    # Act
    get '/post/edit?title=title'

    # Assert
    assert_response :success
  end

  def _create_post_model(parameters)
    post_model = Post.new
    post_model.title = parameters[:title]
    post_model.author = parameters[:author]
    post_model.hero = parameters[:hero]
    post_model.overlay = parameters[:overlay]
    post_model.contents = parameters[:contents]
    post_model.tags = parameters[:tags]
    post_model
  end
end
