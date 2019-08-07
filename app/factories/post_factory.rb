require_relative '../models/post'

##
# This module is a factory for parsing post text and creating a correseponding post model
module PostFactory
  class << self
    ##
    # This method parses markdown in a post a returns a post model
    # 
    # Params:
    # +post_contents+::markdown in a given post
    def create_post(post_contents)      
      return create_post_model(post_contents) if !post_contents.nil? && post_contents.is_a?(String)
    end

  private
    def parse_tags(header)
      result = []
      header.lines.each do |line|
        tag_match = line.match(/\s*-\s*(.*)/)
        result << tag_match.captures.first if tag_match
      end
      result.join(', ')
    end

    def create_post_model(post_contents)
      result = Post.new

      # What this regular expression does is it matches two groups
      # The first group represents the header of the post which appears
      # between the two --- lines. The second group represents the actual post contents
      match_obj = post_contents.match(/---(.*)---\n(.*)/m)
      header = match_obj.captures[0]
      
      parse_post_header(header, result)
      result.contents = match_obj.captures[1]
      result.tags = parse_tags(header)
      result
    end

    def parse_post_header(header, post_model)
      # The following regular expressions in this method look for specific properities
      # located in the post header.
      post_model.title = header.match(/title:\s*(.*)\n/).captures.first
      post_model.author = header.match(/author:\s*(.*)\n/).captures.first
      post_model.hero = header.match(/hero:\s*(.*)\n/).captures.first
      post_model.overlay = header.match(/overlay:\s*(.*)\n/).captures.first
    end
  end
end
