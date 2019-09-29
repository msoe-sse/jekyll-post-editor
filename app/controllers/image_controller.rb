##
# This controller deals with routes for attaching photos to an SSE post
# Note: this should really inherit from BasePostEditorController but doesn't
# since this controller makes AJAX POST requests which won't save the session[:access_token]
# variable
class ImageController < BasePostEditorController
  skip_before_action :verify_authenticity_token

  # POST image/upload
  def upload
    PostImageManager.instance.add_file(params[:file])
    render plain: 'OK'
  end
end
