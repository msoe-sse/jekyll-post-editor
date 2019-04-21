require 'kramdown'

class HomeController < ApplicationController
  def index
  end

  # POST home/preview
  def preview
    kramdown_html = Kramdown::Document.new(params[:text]).to_html
    render json: {
        html: kramdown_html
    }
  end

  #POST home/submit
  def submit

  end
end
