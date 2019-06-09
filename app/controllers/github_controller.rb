class GithubController < ApplicationController
  def callback
    session_code = params[:code]
    session[:access_token] = GithubService.get_oauth_access_token(session_code)
  end
end