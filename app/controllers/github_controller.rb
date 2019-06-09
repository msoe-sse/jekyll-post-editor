##
# This controller contains specific code for handling GitHub specific urls
class GithubController < ApplicationController
  ##
  # This method handles the oauth callback url after a user authorizes 
  # the post editor with their GitHub account. For more information about this controller method
  # see https://developer.github.com/v3/guides/basics-of-authentication/
  def callback
    session_code = params[:code]
    session[:access_token] = GithubService.get_oauth_access_token(session_code)
    redirect_to '/'
  end
end