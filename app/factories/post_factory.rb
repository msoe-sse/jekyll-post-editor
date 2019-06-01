require_relative '../models/post'

module PostFactory
  class << self
    def create_post(post_contents)
      result = nil
      
      if post_contents != nil && post_contents.kind_of?(String)
        result = Post.new

        match_obj = post_contents.match /---(.*)---\n(.*)/m
        header = match_obj.captures[0]
        
        result.contents = match_obj.captures[1]
        result.title = header.match(/title:\s*(.*)\n/).captures.first
        result.author = header.match(/author:\s*(.*)\n/).captures.first
        result.tags = _parse_tags(header)

        result.hero = header.match(/hero:\s*(.*)\n/).captures.first
        result.overlay = header.match(/overlay:\s*(.*)\n/).captures.first
        
      end

      result
    end

    def _parse_tags(header)
      result = []
      header.lines.each do |line|
        tag_match = line.match(/\s*-\s*(.*)/)
        if tag_match then result << tag_match.captures.first end
      end
      result
    end
  end
end