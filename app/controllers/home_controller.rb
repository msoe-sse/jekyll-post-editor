class HomeController < ApplicationController
  #POST home/login
  def login
    access_token = GithubService.authenticate(params[:username], params[:login][:password])
    if access_token == :unauthorized
      validation_message = 'Invalid GitHub username or password'
      redirect_to '/', :alert => validation_message
    elsif access_token == :not_in_organization
      validation_message = 'The GitHub user provided is not apart of the msoe-sse GitHub organization. Please contact the SSE Webmaster for assistance.'
      redirect_to '/', :alert => validation_message
    else
      session[:access_token] = access_token
      redirect_to :controller => 'post', :action => 'list'
    end
  end
end
