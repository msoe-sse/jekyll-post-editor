class HomeController < ApplicationController
  #POST home/login
  def login
    client = GithubService.authenticate(params[:username], params[:login][:password])
    if client == :unauthorized
      validation_message = 'Invalid GitHub username or password'
      redirect_to '/', :alert => validation_message
    elsif client == :not_in_organization
      validation_message = 'The GitHub user provided is not apart of the msoe-sse GitHub orginization. Please contact the SSE Webmaster for assistance.'
      redirect_to '/', :alert => validation_message
    else
      session[:github_client] = client
      redirect_to '/post/list'
    end
  end
end
