require 'test_helper'
require 'mocha/setup'
require 'octokit'
require 'base64'
require 'date'

class GithubServiceTest < ActiveSupport::TestCase
  # Note the client id and client secret values are set in test_helper.rb
  test 'get_authorization_url should get the correct authorization url with the public_repo scope' do 
    # Arrange
    auth_url = 'https://github.com/login/oauth/authorize?client_id=github client id&scope=public_repo+read%3Aorg'
    Octokit::Client.any_instance.expects(:authorize_url)
                   .with('github client id', scope: 'public_repo read:org').returns(auth_url)

    # Act
    result = GithubService.get_authorization_url

    # Assert
    assert_equal auth_url, result
  end

  test 'get_oauth_access_token should return a oauth access token for a GitHub user' do 
    # Arrange
    Octokit.expects(:exchange_code_for_token).with('session code', 'github client id', 'github client secret')
           .returns(access_token: 'oauth access token')

    # Act
    access_token = GithubService.get_oauth_access_token('session code')

    # Assert
    assert_equal 'oauth access token', access_token
  end

  test 'check_access_token should return false if the oauth access token provided is invalid' do 
    # Arrange
    Octokit::Client.any_instance.expects(:check_application_authorization)
                                .with('access token').raises(Octokit::Unauthorized)

    # Act
    result = GithubService.check_access_token('access token')

    # Assert
    assert_not result
  end

  test 'check_access_token should return true if the oauth access token provided is valid' do 
    # Arrange
    Octokit::Client.any_instance.expects(:check_application_authorization).with('access token').returns('result')

    # Act
    result = GithubService.check_access_token('access token')

    # Assert
    assert result
  end

  test 'check_sse_github_org_membership should return true if a user is a member of the msoe-sse GitHub org' do 
    # Arrange
    Octokit::Client.any_instance.expects(:user).returns(login: 'username')
    Octokit::Client.any_instance.expects(:organization_member?).with('msoe-sse', 'username').returns(true)

    # Act
    result = GithubService.check_sse_github_org_membership('access token')

    # Assert
    assert result
  end

  test 'check_sse_github_org_membership should return false if a user is a member of the msoe-sse GitHub org' do 
    # Arrange
    Octokit::Client.any_instance.expects(:user).returns(login: 'username')
    Octokit::Client.any_instance.expects(:organization_member?).with('msoe-sse', 'username').returns(false)

    # Act
    result = GithubService.check_sse_github_org_membership('access token')

    # Assert
    assert_not result
  end

  test 'get_all_posts should return all posts from the msoe-sse website' do 
    # Arrange
    post1 = create_dummy_api_resource(path: '_posts/post1.md')
    post2 = create_dummy_api_resource(path: '_posts/post2.md')
    post3 = create_dummy_api_resource(path: '_posts/post3.md')

    post1_content = create_dummy_api_resource(path: '_posts/post1.md', content: 'post 1 base 64 content')
    post2_content = create_dummy_api_resource(path: '_posts/post2.md', content: 'post 2 base 64 content')
    post3_content = create_dummy_api_resource(path: '_posts/post3.md', content: 'post 3 base 64 content')
    image1_content = create_dummy_api_resource(content: 'imagecontents1', path: 'My File1.jpg')
    image2_content = create_dummy_api_resource(content: 'imagecontents2', path: 'My File2.jpg')

    post1_markdown = "#post1\r\n![My Alt Text](/assets/img/My File1.jpg)\r\n![My Alt Text](/assets/img/My File2.jpg)"

    post1_model = create_post_model(title: 'post 1', author: 'Andy Wojciechowski', hero: 'hero 1',
                                     overlay: 'overlay 1', contents: post1_markdown, tags: ['announcement', 'info'])
    post2_model = create_post_model(title: 'post 2', author: 'Grace Fleming', hero: 'hero 2',
                                     overlay: 'overlay 2', contents: '##post2', tags: ['announcement'])
    post3_model = create_post_model(title: 'post 3', author: 'Sabrina Stangler', hero: 'hero 3',
                                     overlay: 'overlay 3', contents: '###post3', tags: ['info'])

    Octokit::Client.any_instance.expects(:commits)
                                .with('msoe-sse/jekyll-post-editor-test-repo', path: '_posts/post1.md')
                                .returns([ create_commit_hash('2011-04-14T16:00:49Z', 'andy-wojciechowski'),
                                           create_commit_hash('2011-05-14T16:00:49Z', 'andy-wojciechowski')])
    
    Octokit::Client.any_instance.expects(:commits)
                                .with('msoe-sse/jekyll-post-editor-test-repo', path: '_posts/post2.md')
                                .returns([ create_commit_hash('2011-04-14T16:00:49Z', 'GFLEMING133'),
                                           create_commit_hash('2012-04-14T16:00:49Z', 'andy-wojciechowski') ])
    
    Octokit::Client.any_instance.expects(:commits)
                                .with('msoe-sse/jekyll-post-editor-test-repo', path: '_posts/post3.md')
                                .returns([ create_commit_hash('2011-04-14T16:00:49Z', 'andy-wojciechowski') ])

    Octokit::Client.any_instance.expects(:user).returns(login: 'andy-wojciechowski').at_least_once

    KramdownService.expects(:get_all_image_paths).with(post1_markdown)
                   .returns(['assets/img/My File1.jpg', 'assets/img/My File2.jpg'])
    KramdownService.expects(:get_all_image_paths).with('##post2').never
    KramdownService.expects(:get_all_image_paths).with('###post3').returns([])

    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: '_posts')
                   .returns([post1, post2, post3])
    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: '_posts/post1.md')
                   .returns(post1_content)
    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: '_posts/post2.md')
                   .returns(post2_content).never
    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: '_posts/post3.md')
                   .returns(post3_content)
    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: 'assets/img/My File1.jpg')
                   .returns(image1_content)
    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: 'assets/img/My File2.jpg')
                   .returns(image2_content)

    Base64.expects(:decode64).with('post 1 base 64 content').returns('post 1 text content')
    Base64.expects(:decode64).with('post 2 base 64 content').returns('post 2 text content').never
    Base64.expects(:decode64).with('post 3 base 64 content').returns('post 3 text content')
    
    PostFactory.expects(:create_post).with('post 1 text content', '_posts/post1.md', nil).returns(post1_model)
    PostFactory.expects(:create_post).with('post 2 text content', '_posts/post2.md', nil).returns(post2_model).never
    PostFactory.expects(:create_post).with('post 3 text content', '_posts/post3.md', nil).returns(post3_model)

    # Act
    result = GithubService.get_all_posts('my token')

    # Assert
    assert_equal [post1_model, post3_model], result

    assert_equal 2, post1_model.images.length
    assert_post_image('assets/img/My File1.jpg', 'imagecontents1', post1_model.images[0])
    assert_post_image('assets/img/My File2.jpg', 'imagecontents2', post1_model.images[1])

    assert_equal 0, post3_model.images.length
  end

  test 'get_all_posts_in_pr_for_user should return all posts in PR for a user' do 
    # Arrange
    post_content = create_dummy_api_resource(content: 'PR base 64 content', path: 'sample.md')
    image_content = create_dummy_api_resource(content: 'imagecontents', path: 'sample.jpeg')
    post_model = create_post_model(title: 'post', author: 'Andy Wojciechowski', hero: 'hero',
                                   overlay: 'overlay', contents: '#post', tags: ['announcement', 'info'])

    Octokit::Client.any_instance.expects(:user).returns(login: 'andy-wojciechowski').at_least_once

    Octokit::Client.any_instance.expects(:pull_requests).with('msoe-sse/jekyll-post-editor-test-repo', state: 'open')
                   .returns([create_pull_request_hash('msoe-sse-webmaster', 
                            'This pull request was opened automatically by the jekyll-post-editor.', 1),
                            create_pull_request_hash('andy-wojciechowski', 'My Pull Request Body', 2),
                            create_pull_request_hash('andy-wojciechowski', 
                            'This pull request was opened automatically by the jekyll-post-editor.', 3)])
    
    Octokit::Client.any_instance.expects(:pull_request_files).with('msoe-sse/jekyll-post-editor-test-repo', 1)
                   .returns([]).never
    Octokit::Client.any_instance.expects(:pull_request_files).with('msoe-sse/jekyll-post-editor-test-repo', 2)
                   .returns([]).never
    Octokit::Client.any_instance.expects(:pull_request_files).with('msoe-sse/jekyll-post-editor-test-repo', 3).returns([
      create_pull_request_file_hash('myref', 'sample.md'),
      create_pull_request_file_hash('myref', 'sample.jpeg')
    ])

    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: 'sample.md', ref: 'myref')
                   .returns(post_content)

    Octokit::Client.any_instance.expects(:contents)
                   .with('msoe-sse/jekyll-post-editor-test-repo', path: 'sample.jpeg', ref: 'myref')
                   .returns(image_content) 
    
    Base64.expects(:decode64).with('PR base 64 content').returns('PR content')
    PostFactory.expects(:create_post).with('PR content', 'sample.md', 'myref').returns(post_model)

    # Act
    result = GithubService.get_all_posts_in_pr_for_user('my token')

    # Assert
    assert_equal [post_model], result

    assert_equal 1, post_model.images.length
    assert_post_image('sample.jpeg', 'imagecontents', post_model.images.first)
  end
  
  test 'get_post_by_title should return nil if the post does not exist' do
    # Arrange
    post1_model = create_post_model(title: 'post 1', author: 'Andy Wojciechowski', hero: 'hero 1',
                                     overlay: 'overlay 1', contents: '#post1', tags: ['announcement', 'info'])
    post2_model = create_post_model(title: 'post 2', author: 'Grace Fleming', hero: 'hero 2',
                                     overlay: 'overlay 2', contents: '##post2', tags: ['announcement'])
    post3_model = create_post_model(title: 'post 3', author: 'Sabrina Stangler', hero: 'hero 3',
                                     overlay: 'overlay 3', contents: '###post3', tags: ['info'])

    GithubService.expects(:get_all_posts).with('my token').returns([post1_model, post2_model, post3_model])

    # Act
    result = GithubService.get_post_by_title('my token', 'a very fake post', nil)

    # Assert
    assert_nil result
  end

  test 'get_post_by_title should return a given post by its title' do
    # Arrange
    post1_model = create_post_model(title: 'post 1', author: 'Andy Wojciechowski', hero: 'hero 1',
                                     overlay: 'overlay 1', contents: '#post1', tags: ['announcement', 'info'])
    post2_model = create_post_model(title: 'post 2', author: 'Grace Fleming', hero: 'hero 2',
                                     overlay: 'overlay 2', contents: '##post2', tags: ['announcement'])
    post3_model = create_post_model(title: 'post 3', author: 'Sabrina Stangler', hero: 'hero 3',
                                     overlay: 'overlay 3', contents: '###post3', tags: ['info'])

    GithubService.expects(:get_all_posts).with('my token').returns([post1_model, post2_model, post3_model])

    # Act
    result = GithubService.get_post_by_title('my token', 'post 2', nil)

    # Assert
    assert_equal post2_model, result
  end

  test 'get_post_by_title should return nil if the post does not exist on a given ref' do 
    # Arrange
    post1_model = create_post_model(title: 'post 1', author: 'Andy Wojciechowski', hero: 'hero 1',
                                    overlay: 'overlay 1', contents: '#post1', tags: ['announcement', 'info'])
    post2_model = create_post_model(title: 'post 2', author: 'Grace Fleming', hero: 'hero 2',
                                    overlay: 'overlay 2', contents: '##post2', tags: ['announcement'])
    post3_model = create_post_model(title: 'post 3', author: 'Sabrina Stangler', hero: 'hero 3',
                                    overlay: 'overlay 3', contents: '###post3', tags: ['info'])

    GithubService.expects(:get_all_posts_in_pr_for_user)
                 .with('my token').returns([post1_model, post2_model, post3_model])

    # Act
    result = GithubService.get_post_by_title('my token', 'a very fake post', 'ref')

    # Assert
    assert_nil result
  end

  test 'get_post_by_title should return a given post by its title given a ref' do 
    # Arrange
    post1_model = create_post_model(title: 'post 1', author: 'Andy Wojciechowski', hero: 'hero 1',
                                    overlay: 'overlay 1', contents: '#post1', tags: ['announcement', 'info'])
    post2_model = create_post_model(title: 'post 2', author: 'Grace Fleming', hero: 'hero 2',
                                    overlay: 'overlay 2', contents: '##post2', tags: ['announcement'])
    post3_model = create_post_model(title: 'post 3', author: 'Sabrina Stangler', hero: 'hero 3',
                                    overlay: 'overlay 3', contents: '###post3', tags: ['info'])

    GithubService.expects(:get_all_posts_in_pr_for_user)
                 .with('my token').returns([post1_model, post2_model, post3_model])

    # Act
    result = GithubService.get_post_by_title('my token', 'post 2', 'ref')

    # Assert
    assert_equal post2_model, result
  end

  test 'get_master_head_sha should return the sha of the head of master' do 
    # Arrange
    Octokit::Client.any_instance.expects(:ref).with('msoe-sse/jekyll-post-editor-test-repo', 'heads/master')
                   .returns(object: { sha: 'master head sha' })

    # Act
    result = GithubService.get_master_head_sha('my token')

    # Assert
    assert_equal 'master head sha', result
  end

  test 'get_base_tree_for_branch should return the sha of the base tree for a branch' do 
    # Arrange
    Octokit::Client.any_instance.expects(:commit).with('msoe-sse/jekyll-post-editor-test-repo', 'master head sha')
                   .returns(commit: { tree: { sha: 'base tree sha' } })

    # Act
    result = GithubService.get_base_tree_for_branch('my token', 'master head sha')

    # Assert
    assert_equal 'base tree sha', result
  end

  test 'create_text_blob should create a new blob with text content 
        in the SSE website repo and return the sha of the blob' do 
    # Arrange
    Octokit::Client.any_instance.expects(:create_blob)
                                .with('msoe-sse/jekyll-post-editor-test-repo', 'my text')
                                .returns('blob sha')

    # Act
    result = GithubService.create_text_blob('my token', 'my text')

    # Assert
    assert_equal 'blob sha', result
  end

  test 'create_base64_encoded_blob should create a new blob with base 64 encoded content 
        in the SSE website repo and return the sha of the blob' do 
    # Arrange
    Octokit::Client.any_instance.expects(:create_blob)
                                .with('msoe-sse/jekyll-post-editor-test-repo', 'my content', 'base64')
                                .returns('blob sha')

    # Act
    result = GithubService.create_base64_encoded_blob('my token', 'my content')

    # Assert
    assert_equal 'blob sha', result
  end

  test 'create_new_tree_with_blobs should create a new tree in the SSE website repo and return the sha of the tree' do 
    # Arrange
    file_information = [ { path: 'filename1.md', blob_sha: 'blob1 sha' }, 
                         { path: 'filename2.md', blob_sha: 'blob2 sha' }]
    Octokit::Client.any_instance.expects(:create_tree)
                   .with('msoe-sse/jekyll-post-editor-test-repo', 
                         [ create_blob_info_hash(file_information[0][:path], file_information[0][:blob_sha]),
                           create_blob_info_hash(file_information[1][:path], file_information[1][:blob_sha]) ],
                        base_tree: 'base tree sha').returns(sha: 'new tree sha')

    # Act
    result = GithubService.create_new_tree_with_blobs('my token', file_information, 'base tree sha')

    # Assert
    assert_equal 'new tree sha', result
  end

  test 'commit_and_push_to_repo should create a commit and push the commit up to the SSE website repo' do 
    # Arrange
    Octokit::Client.any_instance.expects(:create_commit)
                   .with('msoe-sse/jekyll-post-editor-test-repo', 
                         'Created post Test Post', 'new tree sha', 'master head sha').returns(sha: 'new commit sha')
    Octokit::Client.any_instance.expects(:update_ref)
                   .with('msoe-sse/jekyll-post-editor-test-repo', 'heads/createPostTestPost', 'new commit sha').once

    # Act
    GithubService.commit_and_push_to_repo('my token', 'Created post Test Post', 'new tree sha', 
                                          'master head sha', 'heads/createPostTestPost')

    # No Assert - taken care of with mocha mock setups
  end

  test 'create_pull_request should open a new pull request for the SSE website repo' do 
    # Arrange
    Octokit::Client.any_instance.expects(:create_pull_request)
                   .with('msoe-sse/jekyll-post-editor-test-repo', 
                         'master', 
                         'createPostTestPost', 
                         'Created Post Test Post', 
                         'This pull request was opened automatically by the jekyll-post-editor.').returns(number: 1)
    Octokit::Client.any_instance.expects(:request_pull_request_review)
                   .with('msoe-sse/jekyll-post-editor-test-repo', 1, reviewers: ['msoe-sse-webmaster']).once

    # Act
    GithubService.create_pull_request('my token', 'createPostTestPost', 'master', 
                                      'Created Post Test Post', 
                                      'This pull request was opened automatically by the jekyll-post-editor.',
                                      ['msoe-sse-webmaster'])

    # No Assert - taken care of with mocha mock setups
  end

  test 'create_ref_if_necessary should not create a new branch if the branch already exists' do 
    # Arrange
    Octokit::Client.any_instance.expects(:ref)
                                .with('msoe-sse/jekyll-post-editor-test-repo', 'branchName')
                                .returns('my ref')
    
    Octokit::Client.any_instance.expects(:create_ref)
                                .with('msoe-sse/jekyll-post-editor-test-repo', 'branchName', 'master head sha')
                                .returns('sample response').never

    # Act
    GithubService.create_ref_if_necessary('oauth token', 'branchName', 'master head sha')
    
    # No Assert - taken care of with mocha mock setups
  end

  test 'create_ref_if_necessary should create a new branch if the branch doesnt exist' do 
    # Arrange
    Octokit::Client.any_instance.expects(:ref)
                                .with('msoe-sse/jekyll-post-editor-test-repo', 'branchName')
                                .raises(Octokit::NotFound)
    
    Octokit::Client.any_instance.expects(:create_ref)
                                .with('msoe-sse/jekyll-post-editor-test-repo', 'branchName', 'master head sha')
                                .returns('sample response').once

    # Act
    GithubService.create_ref_if_necessary('oauth token', 'branchName', 'master head sha')
    
    # No Assert - taken care of with mocha mock setups
  end

  test 'get_ref_name_by_sha should return the properly formatted ref name from Octokit' do 
    # Arrange
    response = [
      {
        ref: 'refs/heads/branch1',
        object: {
          sha: 'sha 1'
        }
      },
      {
        ref: 'refs/heads/branch2',
        object: {
          sha: 'sha 2'
        }
      },
      {
        ref: 'refs/heads/branch3',
        object: {
          sha: 'sha 3'
        }
      }
    ]

    Octokit::Client.any_instance.expects(:refs).with('msoe-sse/jekyll-post-editor-test-repo').returns(response)

    # Act
    result = GithubService.get_ref_name_by_sha('my token', 'sha 2')

    # Assert
    assert_equal 'heads/branch2', result
  end
  
  private
    def create_dummy_api_resource(parameters)
      resource = DummyApiResource.new
      resource.path = parameters[:path]
      resource.content = parameters[:content]
      resource
    end

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

    def create_blob_info_hash(file_path, blob_sha)
      { path: file_path,
        mode: '100644',
        type: 'blob',
        sha: blob_sha } 
    end

    def create_commit_hash(date, login)
      # For more information on how this hash was created see: 
      # https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository
      {
        commit: {
          committer: {
            date: date
          }
        },
        author: {
          login: login
        }
      }
    end

    def create_pull_request_hash(username, body, number)
      {
        user: {
          login: username
        },
        body: body,
        number: number
      }
    end

    def create_pull_request_file_hash(ref, filename)
      {
        contents_url: "http://example.com?ref=#{ref}",
        filename: filename
      }
    end

    def assert_post_image(filename, contents, actual)
      assert_equal filename, actual.filename
      assert_equal contents, actual.contents
    end

    class DummyApiResource
      attr_accessor :path
      attr_accessor :content
    end
end
