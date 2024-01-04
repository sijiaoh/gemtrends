class Rubygem
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string

  validates :name, format: { with: /\A[a-z0-9\-_]+\z/ }

  # @return [Array<Hash>]
  # @option return [ActiveSupport::TimeWithZone] :date
  # @option return [Integer] :total_downloads
  def daily_total_downloads
    @daily_total_downloads ||= fetch_source_data.map do |datum|
      { date: Time.zone.parse(datum["date"]), total_downloads: datum["total_downloads"] }
    end
  end

  # @return [Array<Hash>] Same as #daily_total_downloads, but weekly.
  def weekly_total_downloads
    @weekly_total_downloads ||= daily_total_downloads.each_with_object([]).with_index do |(datum, arr), index|
      if (index % 7).zero?
        arr << { date: datum[:date], total_downloads: datum[:total_downloads] }
      else
        arr.last[:total_downloads] += datum[:total_downloads]
      end
    end
  end

  private

  # Return value is like this:
  # https://github.com/xmisao/bestgems.org/wiki/BestGems-API-v1-Specification#total-downloads-trends
  # [{"date":"2014-07-16","total_downloads":123},
  #  {"date":"2014-07-15","total_downloads":456},
  #  {"date":"2014-07-14","total_downloads":789}]
  def fetch_source_data
    raise "Should mock Rubygem#fetch_source_data in test." if Rails.env.test?

    res = Rails.cache.fetch("https://bestgems.org/api/v1/gems/#{name}/total_downloads.json", expires_in: 12.hours) do
      Faraday.get "https://bestgems.org/api/v1/gems/#{name}/total_downloads.json"
    end
    JSON.parse res.body
  rescue StandardError
    []
  end
end
