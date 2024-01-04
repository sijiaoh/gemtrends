FactoryBot.define do
  factory :chart do
    query { "rails" }
    period { ChartPeriod.new(type: :all_time) }
  end
end
