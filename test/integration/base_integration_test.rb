require 'test_helper'
require 'mocha/minitest'

##
# The base class for all integration tests which includes operations common to all integration tests.
class BaseIntegrationTest < ActionDispatch::IntegrationTest
  protected
    def setup_session(access_token, is_valid_token)
      session = { access_token: access_token }
      PostController.any_instance.expects(:session).at_least(0).returns(session)
      ImageController.any_instance.expects(:session).at_least(0).returns(session)
      GithubService.expects(:check_access_token).with(access_token).returns(is_valid_token)
    end
end
