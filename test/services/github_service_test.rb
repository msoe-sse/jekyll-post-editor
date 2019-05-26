require 'test_helper'
require 'mocha/setup'
require 'octokit'

class GithubServiceTest < ActiveSupport::TestCase
  test 'authenticate should return nil on failed authentication' do 
    Octokit::Client.any_instance.expects(:user).raises(Octokit::Unauthorized)
    result = GithubService.authenticate('test', 'test')
    assert_nil result
  end  
end