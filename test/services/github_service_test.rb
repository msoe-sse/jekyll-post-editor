require 'test_helper'

class GithubServiceTest < ActiceSupport::TestCase
  test 'authenticate should return nil on failed authentication' do 
    result = GithubService.authenticate('test', 'test')
    #TODO: Finish this test
  end  
end