require_relative '../error/error'

##
# The base controller class for this application in which all controllers derive from
class ApplicationController < ActionController::Base
  include ErrorHandlers
end
