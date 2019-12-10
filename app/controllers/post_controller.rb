require 'uri'

##
# The controller responsible for dealing with views related to SSE website posts
class PostController < BasePostEditorController
  # GET post/list
  def list
    PostImageManager.instance.clear
    @pr_posts = GithubService.get_all_posts_in_pr_for_user(session[:access_token])
    @posts = GithubService.get_all_posts(session[:access_token]).select do | post |
      found_post = @pr_posts.find { |x| x.title == post.title }
      post if !found_post
    end
    @posts.compact!
  end
  
  # GET post/edit
  def edit
    @post = Post.new
    create_post_from_session if session[:post_stored]
    # The ref parameter is for indicating editing a post that is apart of an open pull request. The ref parameter
    # itself is a sha pointing to the head of the base branch in that open pull request.
    @post = GithubService.get_post_by_title(session[:access_token], params[:title], params[:ref]) if params[:title]
  end

  # GET post/preview
  def preview
    kramdown_html = KramdownService.get_preview(params[:text])
    render json: {
      html: kramdown_html
    }
  end

  # POST post/submit
  def submit
    error_message = validate_submission_parameters(params[:title], params[:author], params[:markdownArea],
                                                                                                    params[:hero])
    if error_message
      store_post_parameters_in_session
      redirect_to '/post/edit', alert: error_message
    else
      full_post_text = KramdownService.create_jekyll_post_text(params[:markdownArea], params[:author], 
                                                               params[:title], params[:tags],
                                                               params[:overlay], params[:hero])
      
      if params[:path] && params[:ref]
        PostService.edit_post_in_pr(session[:access_token], full_post_text, params[:title], params[:path], params[:ref])
      elsif params[:path]
        PostService.edit_post(session[:access_token], full_post_text, params[:title], params[:path])
      else
        PostService.create_post(session[:access_token], full_post_text, params[:title])
      end
      flash[:notice] = 'Post Successfully Submited'
      redirect_to action: 'list'
    end
  end

  private
    def validate_submission_parameters(title, author, markdown_text, hero)
      validation_message = nil
      if title.empty?
        validation_message = 'A post cannot be submited with a blank title.'
      elsif author.empty?
        validation_message = 'A post cannot be submited without an author.'
      elsif markdown_text.empty?
        validation_message = 'A post cannot be submited with no markdown content.' 
      elsif !hero.empty? && !(hero =~ URI.regexp)
        validation_message = 'The background image must be a valid URL.'
      elsif !hero.empty? && !PostService.is_valid_hero(hero)
        validation_message = 'The background image url must be an image.'
      end
      validation_message
    end

    def store_post_parameters_in_session
      session[:post_stored] = true
      session[:title] = params[:title]
      session[:author] = params[:author]
      session[:contents] = params[:markdownArea]
      session[:tags] = params[:tags]
      session[:overlay] = params[:overlay]
      session[:hero] = params[:hero]
    end

    def create_post_from_session
      @post = Post.new
      @post.title = session[:title]
      @post.author = session[:author]
      @post.contents = session[:contents]
      @post.tags = session[:tags]
      @post.overlay = session[:overlay]
      @post.hero = session[:hero]
      session[:post_stored] = false
    end
end
