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
      # https://source.unsplash.com/collection/145103/
      parsed_tags = parse_tags(tags)

      tag_section = %(tags:
#{parsed_tags})
      
      lead_break_section = "{: .lead}\r\n<!–-break-–>"
          
      result = %(---
layout: post
title: #{title}
author: #{author}\r\n)

      result << "#{tag_section}\r\n" if !parsed_tags.empty?
      result << %(hero: https://source.unsplash.com/collection/145103/
overlay: #{overlay.downcase}
published: true
---
#{lead_break_section}
#{text})

      result
    end

    private
      def parse_tags(tags)
        tags_no_whitepsace = tags.gsub(/\s+/, '')
        tag_array = tags_no_whitepsace.split(',')
        result = ''
        tag_array.each do |tag|
          result << "  - #{tag}"
          result << "\r\n" if tag != tag_array.last
        end
        result
      end
  end
end
