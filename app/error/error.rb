require 'octokit'

##
# This module includes custom methods related to program errors in rails
module Error
  ##
  # This module includes different custom global error handlers
  module ErrorHandler
    ##
    # This method rescues controller method calls from certain exceptions
    # and will handle them in a unique way
    # 
    # Params:
    # +clazz+::the class that this module was included in
    def self.included(clazz)
      clazz.class_eval do 
        rescue_from Octokit::TooManyRequests, :with => :rate_limit_error
      end
    end
  
    private
    def rate_limit_error
      render :template => 'public/RateLimitError.html'
    end
  end
end