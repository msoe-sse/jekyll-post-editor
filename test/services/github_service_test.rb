require 'test_helper'
require 'github_service'

class GithubServiceTest < ActiceSupport::TestCase
  test 'authenticate returns nil on failed authentication' do 
    result = GithubService::authenticate('test', 'test')
    #TODO: Finish this test
  end
end