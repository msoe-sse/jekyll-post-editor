require 'kramdown'

class HomeController < ApplicationController
  def index
    @kramdown_html = ""
  end

  # GET /preview
  def preview
    @kramdown_html = Kramdown::Document.new(params[:text]).to_html
  end
end
