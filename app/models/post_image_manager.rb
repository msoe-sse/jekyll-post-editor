require 'singleton'

##
# A singleton class for managing all image attachments for a post
class PostImageManager
  include Singleton
  
  attr_reader :uploaders

  ##
  # The constructor for PostImageManager which initializes the array of Carrierware
  # image uploaders to use when submiting a post
  def initialize
    @uploaders = []
  end

  ##
  # Adds an image to be uploaded in a SSE website post
  #
  # Params:
  # +file+:: A ActionDispatch::Http::UploadedFile object containing the file to be used in a post
  def add_file(file)
    uploader_to_add = PostImageUploader.new
    uploader_to_add.cache!(file)
    @uploaders << uploader_to_add
  end

  ##
  # Clears the manager of all currently exisiting image uploaders
  def clear
    @uploaders.clear
  end
end
