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

    ##
    # This method takes parameters for a given post and formats them
    # as a valid jekyll post for the SSE website
    #
    # Params:
    # +text+:: the markdown contents of the post
    # +author+:: the author of the post
    # +title+:: the title of the post
    # +tags+:: tags specific to the post
    # +overlay+:: the overlay color of the post
    def create_jekyll_post_text(text, author, title, tags, overlay)
      header_converted_text = fix_header_syntax(text)
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
#{header_converted_text})

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

      def fix_header_syntax(text)
        document = Kramdown::Document.new(text)
        header_elements = document.root.children.select { |x| x.type == :header }
        lines = text.split("\n")
        lines = lines.map do |line|
          if header_elements.any? { |x| line.include? x.options[:raw_text] }
            # This regex matches the line into 2 groups with the first group being the repeating #
            # characters and the beginning of the string and the second group being the rest of the string
            line_match = line.match(/(#*)(.*)/)
            line = "#{line_match.captures.first} #{line_match.captures.last.strip}"
          else
            line.delete("\r\n")
          end
        end
        lines.join("\r\n")
      end
  end
end
