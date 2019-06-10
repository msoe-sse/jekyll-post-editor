require_relative '../error/error'

class ApplicationController < ActionController::Base
  include Error::ErrorHandler
  protect_from_forgery prepend: true
  before_action :check_authentication

  private
  ##
  # This method gets called before every action in a controller. First, it checks to see
  # if we are authenticated by checking to see if a oauth access token is stored in the session. 
  # If not, we redirect to the GitHub authorization url to authorize a user's GitHub account
  # with the post editor. If we do have an access token in the session we check to see if it's valid
  # and if it's not we restart the authenticate flow.
  def check_authentication
    if !authenticated?
      authenticate!
    else
      access_token = session[:access_token]
      is_token_valid = GithubService.check_access_token(access_token)
      if !is_token_valid
        session[:access_token] = nil
        authenticate!
      end
    end
  end

  def authenticated?
    session[:access_token]
  end

  def authenticate!
    auth_url = GithubService.get_authorization_url
    redirect_to auth_url
  end
end
