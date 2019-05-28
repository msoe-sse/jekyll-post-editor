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
        #result.tags = header.to_enum(:scan, /\s*-\s*(.*)/m).map { Regexp.last_match.captures.first }
        result.hero = header.match(/hero:\s*(.*)\n/).captures.first
        result.overlay = header.match(/overlay:\s*(.*)\n/).captures.first
        
      end

      result
    end
  end
end