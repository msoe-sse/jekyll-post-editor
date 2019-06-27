require 'kramdown'

##
# This module contains all operations with interacting with the kramdown engine
module KramdownService
  class << self
    ##
    # This method takes given markdown and converts it to HTML
    # 
    # Params:
    # +text+:: markdown to convert to html
    def get_html(text)
      Kramdown::Document.new(text).to_html
    end

    def create_jekyll_post_text(text, author, title, tags, overlay)
      # TODO: Implement This, Note default the hero to https://source.unsplash.com/collection/145103/
    end
  end
end
