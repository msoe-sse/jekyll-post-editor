require 'kramdown'

class HomeController < ApplicationController
  def index
  end

  # GET /preview
  def preview
    kramdown_html = Kramdown::Document.new(params[:text]).to_html
    render json: {
        html: kramdown_html
    }
  end
end
