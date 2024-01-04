class ChartController < ApplicationController
  def index
    # @type [String] query is a space-separated list of rubygem names.
    query = params[:query]

    @chart = Chart.new query:
  end
end
