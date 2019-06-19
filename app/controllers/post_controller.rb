##
# The controller responsible for dealing with views related to SSE website posts
class PostController < ApplicationController
  # GET post/list
  def list
    @posts = GithubService.get_all_posts(session[:access_token])
  end
  
  # GET post/edit
  def edit
    @post = Post.new
    @post = GithubService.get_post_by_title(session[:access_token], params[:title]) if params[:title]
  end

  # POST post/preview
  def preview
    kramdown_html = KramdownService.get_html(params[:text])
    render json: {
      html: kramdown_html
    }
  end

  # POST post/submit
  def submit
    full_post_text = KramdownService.create_jekyll_post_text(params[:markdownArea], params[:author], params[:title])
    GithubService.submit_post(full_post_text, params[:markdownArea])
    redirect_to action: 'index'
  end
end
