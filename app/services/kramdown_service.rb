require 'kramdown'

##
# This modules contains extentions of the Kramdown::Convert module for custom kramdown converters
module Kramdown::Converter
  ##
  # A custom kramdown HTML converter for getting the HTML preview for a post
  class Preview < Html
    ##
    # An override of the convert_img tag which converts all image sources to pull
    # from the CarrierWare cache location if an uploader exists with the image's filename
    #
    # Params:
    # +el+::the image element to convert to html
    # +_indent+::the indent of the HTML
    def convert_img(el, _indent)
      formatted_filename = File.basename(el.attr['src']).tr(' ', '_') 
      uploader = PostImageManager.instance.uploaders.find { |x| x.filename == formatted_filename }
      el.attr['src'] = "/uploads/tmp/#{uploader.preview.cache_name}" if uploader
      super(el, _indent)
    end
  end
end

##
# This module contains all operations with interacting with the kramdown engine
module KramdownService
  class << self
    ##
    # This method takes given markdown and converts it to HTML for the post preview
    # 
    # Params:
    # +text+:: markdown to convert to html
    def get_preview(text)
      Kramdown::Document.new(text).to_preview
    end

    ##
    # This method returns the image filename given some markdown
    #
    # Params:
    # +image_file_name+:: a filename of a image to look for in markdown
    # +markdown+:: text of a markdown post
    def get_image_filename_from_markdown(image_file_name, markdown)
      document = Kramdown::Document.new(markdown)
      document_descendants = []

      get_document_descendants(document.root, document_descendants)
      all_img_tags = document_descendants.select { |x| x.type == :img }
      matching_image_tag = all_img_tags.find { |x| get_filename_for_image_tag(x).tr(' ', '_') == image_file_name }
      
      return get_filename_for_image_tag(matching_image_tag) if matching_image_tag
      nil
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
    def create_jekyll_post_text(text, author, title, tags, overlay, hero)
      header_converted_text = fix_header_syntax(text)
      header_converted_text = add_line_break_to_markdown_if_necessary(header_converted_text)
      
      parsed_tags = parse_tags(tags)

      tag_section = %(tags:
#{parsed_tags})
      
      lead_break_section = "{: .lead}\r\n<!–-break-–>"
      
      hero_to_use = hero
      hero_to_use = 'https://source.unsplash.com/collection/145103/' if hero_to_use.empty?
      result = %(---
layout: post
title: #{title}
author: #{author}\r\n)

      result << "#{tag_section}\r\n" if !parsed_tags.empty?
      result << %(hero: #{hero_to_use}
overlay: #{overlay.downcase}
published: true
---
#{lead_break_section}
#{header_converted_text})

      result
    end

    private
      def parse_tags(tags)
        tag_array = tags.split(',')
        result = ''
        tag_array.each do |tag|
          result << "  - #{tag.strip}"
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

      def get_document_descendants(current_element, result)
        current_element.children.each do |element|
          result << element
          get_document_descendants(element, result)
        end
      end

      def get_filename_for_image_tag(image_el)
        File.basename(image_el.attr['src'])
      end

      def add_line_break_to_markdown_if_necessary(markdown)
        lines = markdown.split("\n")
        # The regular expression in the if statement looks for a markdown reference to a link like
        # [logo]: https://ieeextreme.org/wp-content/uploads/2019/05/Xtreme_colour-e1557478323964.png
        # If a post starts with that reference in jekyll followed by an image using that reference
        # the line below will be interperted as a paragraph tag instead of an image tag. To fix that
        # we add a line break to the start of the markdown.
        return "\r\n#{markdown}" if lines.first && lines.first.match?(/\[(.*)\]: (.*)/)
        markdown
      end
  end
end
