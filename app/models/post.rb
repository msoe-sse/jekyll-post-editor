class PostImage
  attr_accessor :filename
  attr_accessor :contents
end

##
# An object representing a post on the SSE website
class Post
  attr_accessor :title
  attr_accessor :author
  attr_accessor :hero
  attr_accessor :overlay
  attr_accessor :contents
  attr_accessor :tags
  # Path to the markdown post starting at the root of the repository
  attr_accessor :file_path
  # The GitHub ref the post's markdown is at. This is used to indicate
  # whether a post is in PR or not
  attr_accessor :github_ref
  attr_accessor :images

  def initialize
    @images = []
  end
end
