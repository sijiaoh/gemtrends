class HomeController < ApplicationController
  def index
    @chart = Chart.new
  end
end
