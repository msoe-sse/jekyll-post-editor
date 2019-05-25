require 'test_helper'

class GithubServiceTest < ActiceSupport::TestCase
  fixtures :github_service
  
  def test_authenticate_failed_authenticaiton 
    result = GithubService.authenticate('test', 'test')
    #TODO: Finish this test
  end
end