require 'octokit'

module Error
  module ErrorHandler
    def self.included(clazz)
      clazz.class_eval do 
        rescue_from Octokit::TooManyRequests, with: rate_limit_error
      end
    end
  
    private
    def rate_limit_error
      render :template => 'public/RateLimitError.html'
    end
  end
end