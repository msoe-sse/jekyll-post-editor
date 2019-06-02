require 'octokit'
require 'base64'

module GithubService
  class << self
    def authenticate(username, password)
      client = Octokit::Client.new(:login => username, :password => password)
      begin
        if not client.organization_member?(Rails.configuration.github_org, client.user.login)
          return :not_in_organization
        else
          return _get_oauth_token(client)
        end
      rescue Octokit::Unauthorized
        return :unauthorized
      end
    end

    def get_all_posts
      result = []
      full_repo_name = "#{Rails.configuration.github_org}/#{Rails.configuration.github_repo_name}"
      posts = Octokit.contents(full_repo_name, :path => '_posts')
      posts.each do |post|
        post_api_response = Octokit.contents(full_repo_name, :path => post.path)
        text_contents = Base64.decode64(post_api_response.content)
        result << PostFactory.create_post(text_contents)
      end
      result
    end

    def submit_post(post_markdown, author)
      #TODO: Authentication with client = Octokit::Client.new(:access_token => "<your 40 char token>")
      #TODO: Create Branch for new post
      #TODO: Commit and push new post
      #TODO: Create pull request for new post
    end

    def _get_oauth_token(client)
      authorization = client.authorizations.find { |x| x[:app][:name] == Rails.configuration.oauth_token_name}
      if authorization
        return authorization[:hashed_token]
      end
      client.create_authorization(:scopes => ['user'], :note => Rails.configuration.oauth_token_name)
    end
  end
end