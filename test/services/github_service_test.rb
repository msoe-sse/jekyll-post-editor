require 'test_helper'

class GithubServiceTest < ActiveSupport::TestCase
  test 'authenticate should return nil on failed authentication' do 
    result = GithubService.authenticate('test', 'test')
    assert_nil result
  end  
end