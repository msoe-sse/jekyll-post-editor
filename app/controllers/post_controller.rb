##
# The controller responsible for dealing with views related to SSE website posts
class PostController < BasePostEditorController
  # GET post/list
  def list
    @posts = GithubService.get_all_posts(session[:access_token])
  end
  
  # GET post/edit
  def edit
    @post = Post.new
    create_post_from_session if session[:post_stored]
    @post = GithubService.get_post_by_title(session[:access_token], params[:title]) if params[:title]
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
    error_message = validate_submission_parameters(params[:title], params[:author], params[:markdownArea])
    if error_message
      store_post_parameters_in_session
      redirect_to '/', alert: error_message
    else
      full_post_text = KramdownService.create_jekyll_post_text(params[:markdownArea], params[:author], 
                                                               params[:title], params[:tags], params[:overlay])
      PostService.submit_post(session[:access_token], full_post_text, params[:title])
      flash[:notice] = 'Post Successfully Submited'
      redirect_to action: 'edit'
    end
  end

  private
    def validate_submission_parameters(title, author, markdown_text)
      validation_message = nil
      if title.empty?
        validation_message = 'A post cannot be submited with a blank title.'
      elsif author.empty?
        validation_message = 'A post cannot be submited without an author.'
      elsif markdown_text.empty?
        validation_message = 'A post cannot be submited with no markdown content.'
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
    end

    def create_post_from_session
      @post = Post.new
      @post.title = session[:title]
      @post.author = session[:author]
      @post.contents = session[:contents]
      @post.tags = session[:tags]
      @post.overlay = session[:overlay]
      session[:post_stored] = false
    end
end
