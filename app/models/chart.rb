class Chart
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :query, :string, default: ""
  # @return [ChartPeriod]
  attribute :period, default: -> { ChartPeriod.new }

  validates :query, format: { with: /\A[a-z0-9\-_\s]+\z/ }

  # JSON for ChartController.js
  # @return [String]
  # @example
  #   { name: [{ date: "2021-01-01", count: 1 }] }
  def to_chart_view_json
    rubygems_by_name.transform_values do |rubygem|
      weekly_downloads_in_period = rubygem.weekly_downloads.take_while do |datum|
        period.in_period?(datum[:date])
      end
      weekly_downloads_in_period.map do |datum|
        { date: datum[:date].strftime("%F"), count: datum[:count] }
      end
    end.to_json
  end

  private

  # @return [Hash<String, Rubygem>] key is rubygem name.
  def rubygems_by_name
    @rubygems_by_name ||= rubygem_names.index_with do |name|
      Rubygem.new(name:)
    end
  end

  def rubygem_names
    query.split(/\s+/)
  end
end
