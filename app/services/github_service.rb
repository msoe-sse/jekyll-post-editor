require 'octokit'

module GithubService
  class << self
    def authenticate(username, password)
      client = Octokit::Client.new(:login => username, :password => password)
      begin
        if not client.organization_member?(Rails.configuration.github_org, client.user.login)
          client = :not_in_organization
        end
      rescue Octokit::Unauthorized
        client = :unauthorized
      end
      client
    end

    def submit_post(post_markdown, author)
      #TODO: Authentication
      #TODO: Create Branch for new post
      #TODO: Commit and push new post
      #TODO: Create pull request for new post
    end
  end
end