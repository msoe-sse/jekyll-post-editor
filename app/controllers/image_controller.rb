##
# This controller deals with routes for attaching photos to an SSE posts
class ImageController < BasePostEditorController
  skip_before_action :verify_authenticity_token

  # POST image/upload
  def upload
    PostImageManager.instance.add_file(params[:file])
    render plain: 'OK'
  end
end
