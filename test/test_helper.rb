require 'simplecov'
SimpleCov.start 'rails'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  ENV['GH_BASIC_CLIENT_ID'] = 'github client id'
  ENV['GH_BASIC_SECRET_ID'] = 'github client secret'
end
