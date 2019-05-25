require 'octokit'

module GithubService
  class << self
    def authenticate(username, password)
      Octokit::Client.new(:login => username, :password => password)
      #TODO: Check that the user belongs to the SSE orginization
    end

    def submit_post(post_markdown, author)
      #TODO: Authentication
      #TODO: Create Branch for new post
      #TODO: Commit and push new post
      #TODO: Create pull request for new post
    end
  end
end