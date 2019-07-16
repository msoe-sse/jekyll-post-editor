##
# This controller deals with routes for attaching photos to an SSE post
class ImageController < ApplicationController # TODO: Make this inherit from base_post_editor_controller.rb
  # POST image/upload
  def upload
    PostImageManager.instance.add_file(params[:file])
    render plain: 'OK'
  end
end
