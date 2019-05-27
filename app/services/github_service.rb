require 'octokit'

module GithubService
  class << self
    def authenticate(username, password)
      client = Octokit::Client.new(:login => username, :password => password)
      begin
        if not client.organization_member?(Rails.configuration.github_org, client.user.login)
          return :not_in_organization
        else
          return client.create_authorizaion(:scopes => ['user'], :note => 'SSE Post Editor Token')
        end
      rescue Octokit::Unauthorized
        return :unauthorized
      end
    end

    def submit_post(post_markdown, author)
      #TODO: Authentication with client = Octokit::Client.new(:access_token => "<your 40 char token>")
      #TODO: Create Branch for new post
      #TODO: Commit and push new post
      #TODO: Create pull request for new post
    end
  end
end