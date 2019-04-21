require 'kramdown'

module KramdownService
  class << self
    def get_html(text)
      Kramdown::Document.new(text).to_html
    end

    def create_jekyll_post_text(text, author, title)
      #TODO: Tags, Hero, Overlay
      %(
      ---
      layout: post
      author: #{author}
      title: #{title}
      published: true
      ---
      #{text}
      )
    end
  end
end