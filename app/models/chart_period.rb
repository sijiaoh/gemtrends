class ChartPeriod
  include ActiveModel::Model
  include ActiveModel::Attributes

  TYPES = %i[
    one_month
    three_months
    six_months
    one_year
    two_years
    five_years
    all_time
  ].freeze

  attribute :type, default: :one_year

  validates :type, inclusion: { in: TYPES }

  def in_period?(date)
    return true if type == :all_time

    date >= start_date
  end

  private

  def start_date
    today = Time.zone.today

    period_date_hash = {
      one_month: today.months_ago(1),
      three_months: today.months_ago(3),
      six_months: today.months_ago(6),
      one_year: today.years_ago(1),
      two_years: today.years_ago(2),
      five_years: today.years_ago(5),
      all_time: nil
    }

    raise "Unexpected type: #{type}" unless period_date_hash.key? type

    period_date_hash[type]
  end
end
