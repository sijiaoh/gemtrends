require "rails_helper"

describe Rubygem do
  subject(:rubygem) { Rubygem.new name: "rails" }

  describe "#name" do
    subject(:rubygem) { Rubygem.new name: }

    let(:name) { "rails" }

    it "is valid" do
      expect(rubygem).to be_valid
    end

    context "when space is included" do
      let(:name) { "rail s" }

      it "is invalid" do
        expect(rubygem).not_to be_valid
      end
    end
  end

  describe "#daily_total_downloads" do
    subject(:daily_total_downloads) { rubygem.daily_total_downloads }

    let(:source_data) do
      # https://github.com/xmisao/bestgems.org/wiki/BestGems-API-v1-Specification#total-downloads-trends
      [
        { "date" => "2014-07-16", "total_downloads" => 123 },
        { "date" => "2014-07-15", "total_downloads" => 456 },
        { "date" => "2014-07-14", "total_downloads" => 789 }
      ]
    end

    before do
      expect_any_instance_of(Rubygem).to receive(:fetch_source_data).and_return(source_data)
    end

    it "returns daily total downloads" do
      expect(daily_total_downloads).to eq(source_data.map do |datum|
        { date: Time.zone.parse(datum["date"]), total_downloads: datum["total_downloads"] }
      end)
    end
  end

  describe "#weekly_total_downloads" do
    subject(:weekly_total_downloads) { rubygem.weekly_total_downloads }

    let(:days) { 14 }
    let(:daily_total_downloads) do
      Array.new(days) do |i|
        { date: Time.zone.parse("2014-07-#{i + 1}"), total_downloads: i + 1 }
      end.reverse
    end

    before do
      expect_any_instance_of(Rubygem).to receive(:daily_total_downloads).and_return(daily_total_downloads)
    end

    it "returns weekly total downloads" do
      expect(weekly_total_downloads).to eq [
        { date: Time.zone.parse("2014-07-14"), total_downloads: 77 },
        { date: Time.zone.parse("2014-07-07"), total_downloads: 28 }
      ]
    end

    context "when last week is not 7 days" do
      let(:days) { 13 }

      it "returns weekly total downloads" do
        expect(weekly_total_downloads).to eq [
          { date: Time.zone.parse("2014-07-13"), total_downloads: 70 },
          { date: Time.zone.parse("2014-07-06"), total_downloads: 21 }
        ]
      end
    end
  end
end
