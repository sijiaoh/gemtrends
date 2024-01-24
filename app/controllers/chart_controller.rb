class ChartController < ApplicationController
  def index
    # @type [String] query is a space-separated list of rubygem names.
    query = params[:query]
    period_type = params[:period]&.to_sym

    period = ChartPeriod.new type: period_type
    @chart = Chart.new query:, period:
  end
end
