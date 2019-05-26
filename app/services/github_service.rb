require 'octokit'

module GithubService
  class << self
    def authenticate(username, password)
      #TODO: Check that the user belongs to the SSE orginization
      client = Octokit::Client.new(:login => username, :password => password)
      begin
        client.user.login
      rescue Octokit::Unauthorized
        client = nil
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