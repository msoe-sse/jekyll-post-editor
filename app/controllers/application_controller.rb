require_relative '../error/error'

##
# The base controller class for this application in which all controllers derive from
class ApplicationController < ActionController::Base
  include ErrorHandlers
  protect_from_forgery prepend: true
end
