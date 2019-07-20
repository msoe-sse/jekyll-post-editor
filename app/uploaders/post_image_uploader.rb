##
# The file uploader class for uploading images to an SSE website post
class PostImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  ##
  # Limits only images to be uploaded to an SSE website post
  def extension_whitelist
    ['jpg', 'jpeg', 'gif', 'png']
  end

  version :preview do 
    process resize_to_limit: [800, 800]
  end

  version :post_image do 
    process resize_to_limit: [800, 700]
  end
end
