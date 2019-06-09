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
      result = nil
      
      if post_contents != nil && post_contents.kind_of?(String)
        result = Post.new

        # What this regular expression does is it matches two groups
        # The first group represents the header of the post which appears
        # between the two --- lines. The second group represents the actual post contents
        match_obj = post_contents.match /---(.*)---\n(.*)/m
        header = match_obj.captures[0]
        
        result.contents = match_obj.captures[1]
        # The following regular expressions in this method look for specific properities
        # located in the post header.
        result.title = header.match(/title:\s*(.*)\n/).captures.first
        result.author = header.match(/author:\s*(.*)\n/).captures.first
        result.tags = parse_tags(header)

        result.hero = header.match(/hero:\s*(.*)\n/).captures.first
        result.overlay = header.match(/overlay:\s*(.*)\n/).captures.first
        
      end

      result
    end

    private
    def parse_tags(header)
      result = []
      header.lines.each do |line|
        tag_match = line.match(/\s*-\s*(.*)/)
        if tag_match then result << tag_match.captures.first end
      end
      result
    end
  end
end