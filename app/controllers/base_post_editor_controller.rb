##
# Base Class for all main controllers in the post editor.
# Controllers should extend this class if we want the user to be authenticated
# before accessing an action in a controller
class BasePostEditorController < ApplicationController
  before_action :check_user

  private
    ##
    # This method gets called before every action in a controller. First, it checks to see
    # if we are authenticated by checking to see if a oauth access token is stored in the session. 
    # If not, we redirect to the GitHub authorization url to authorize a user's GitHub account
    # with the post editor. If we do have an access token in the session we check to see if it's valid
    # and if it's not we restart the authenticate flow.
    #
    # If this user is also fully authenticated but is not apart of the msoe-sse organization
    # an error page will render saying they need to be apart of the msoe-sse organization 
    # in order to use this application
    def check_user
      if !authenticated?
        authenticate!
      else
        access_token = session[:access_token]
        valid_token = GithubService.check_access_token(access_token)
        if !valid_token
          session[:access_token] = nil
          authenticate!
        elsif !GithubService.check_sse_github_org_membership(session[:access_token])
          redirect_to '/GitHubOrgError.html'
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
