require 'kramdown'

module KramdownService
  class << self
    def get_html(text)
      Kramdown::Document.new(text).to_html
    end

    def create_jekyll_post_text(text, author, title)
      #TODO: Implement This
    end
  end
end