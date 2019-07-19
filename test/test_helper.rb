require 'simplecov'
SimpleCov.start 'rails'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  ENV['GH_BASIC_CLIENT_ID'] = 'github client id'
  ENV['GH_BASIC_SECRET_ID'] = 'github client secret'

  protected
    class MockUploader
      attr_accessor :filename
      attr_accessor :cache_name
      attr_accessor :file
     end

     class MockCarrierwareFile
      attr_accessor :file # This actually represents the filepath which matches the carrierware file object
     end

     class MockRubyFile
      attr_accessor :filename

       def read
         "File Contents for #{filename}"
       end
     end

     def create_mock_uploader(filename, cache_name, file)
       result = MockUploader.new
       result.filename = filename
       result.cache_name = cache_name
       result.file = file
       result
     end

     def create_mock_carrierware_file(file)
       result = MockCarrierwareFile.new
       result.file = file
       result
     end
end
