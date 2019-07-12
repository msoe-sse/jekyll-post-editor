##
# The file uploader class for uploading images to an SSE website post
class PostImageUploader < CarrierWave::Uploader::Base
  storage :file

  ##
  # Limits only images to be uploaded to an SSE website post
  def extension_whitelist
    ['jpg', 'jpeg', 'gif', 'png']
  end

end
