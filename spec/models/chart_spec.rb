require "rails_helper"

describe Chart do
  subject(:chart) { build(:chart) }

  describe "#query" do
    subject(:chart) { build(:chart, query:) }

    let(:query) { "pundit cancancan" }

    it "is valid" do
      expect(chart).to be_valid
    end

    context "when ! is included" do
      let(:query) { "pundit!cancan" }

      it "is invalid" do
        expect(chart).not_to be_valid
      end
    end
  end

  describe "#to_chart_view_json" do
    subject(:to_chart_view_json) { chart.to_chart_view_json }

    context "when query has two rubygem names" do
      let(:chart) { build(:chart, query: "pundit cancancan") }

      def stub_rubygem(name)
        rubygem = instance_double(Rubygem, name:)
        expect(rubygem).to receive(:weekly_total_downloads).and_return([])
        expect(Rubygem).to receive(:new).with(name:).and_return(rubygem)
      end

      before do
        stub_rubygem("pundit")
        stub_rubygem("cancancan")
      end

      it "returns two keys" do
        expect(JSON.parse(to_chart_view_json)).to match({ "pundit" => [], "cancancan" => [] })
      end
    end

    context "when rubygem has weekly total downloads" do
      let(:chart) { build(:chart, query: "rails", period:) }
      let(:weekly_total_downloads) do
        [
          { date: Date.new(2021, 3, 1), total_downloads: 3 },
          { date: Date.new(2021, 2, 1), total_downloads: 2 },
          { date: Date.new(2021, 1, 1), total_downloads: 1 }
        ]
      end
      let(:period) { ChartPeriod.new(type: :all_time) }

      before do
        travel_to Date.new(2021, 3, 1)

        expect_any_instance_of(Rubygem).to receive(:weekly_total_downloads).and_return(weekly_total_downloads)
      end

      it "returns all weekly total downloads" do
        expect(JSON.parse(to_chart_view_json)).to match(
          "rails" => [
            { "date" => "2021-03-01", "total_downloads" => 3 },
            { "date" => "2021-02-01", "total_downloads" => 2 },
            { "date" => "2021-01-01", "total_downloads" => 1 }
          ]
        )
      end

      context "when period is one month" do
        let(:period) { ChartPeriod.new(type: :one_month) }

        it "returns weekly total downloads in one month only" do
          expect(JSON.parse(to_chart_view_json)).to match(
            "rails" => [
              { "date" => "2021-03-01", "total_downloads" => 3 },
              { "date" => "2021-02-01", "total_downloads" => 2 }
            ]
          )
        end
      end
    end
  end
end
