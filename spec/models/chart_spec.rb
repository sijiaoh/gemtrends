require "rails_helper"

describe Chart do
  subject(:chart) { Chart.new query: "pundit cancancan" }

  describe "#query" do
    subject(:chart) { Chart.new query: }

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

    def stub_rubygem(name)
      rubygem = instance_double(Rubygem, name:)
      expect(rubygem).to receive(:weekly_total_downloads).and_return([])
      expect(Rubygem).to receive(:new).with(name:).and_return(rubygem)
    end

    before do
      stub_rubygem("pundit")
      stub_rubygem("cancancan")
    end

    it "returns rubygems by name" do
      expect(JSON.parse(to_chart_view_json)).to match({ "pundit" => [], "cancancan" => [] })
    end
  end
end
