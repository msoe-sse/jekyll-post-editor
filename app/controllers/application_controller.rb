require_relative '../error/error'

class ApplicationController < ActionController::Base
  include Error::ErrorHandler
  protect_from_forgery prepend: true
  before_action :check_authentication

  private
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
