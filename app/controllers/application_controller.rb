require_relative '../error/error_handler'

class ApplicationController < ActionController::Base
  include Error::ErrorHandler
  protect_from_forgery prepend: true
end
