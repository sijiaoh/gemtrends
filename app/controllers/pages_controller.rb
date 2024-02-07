class PagesController < ApplicationController
  def home
    @chart = Chart.new
  end
end
