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

  describe "#daily_downloads" do
    subject(:daily_downloads) { rubygem.daily_downloads }

    let(:source_data) do
      # https://github.com/xmisao/bestgems.org/wiki/BestGems-API-v1-Specification#daily-downloads-trends
      [
        { "date" => "2014-07-16", "daily_downloads" => 123 },
        { "date" => "2014-07-15", "daily_downloads" => 456 },
        { "date" => "2014-07-14", "daily_downloads" => 789 }
      ]
    end

    before do
      expect_any_instance_of(Rubygem).to receive(:fetch_source_data).and_return(source_data)
    end

    it "returns daily downloads" do
      expect(daily_downloads).to eq(source_data.map do |datum|
        { date: Time.zone.parse(datum["date"]), count: datum["daily_downloads"] }
      end)
    end
  end

  describe "#weekly_downloads" do
    subject(:weekly_downloads) { rubygem.weekly_downloads }

    let(:days) { 14 }
    let(:daily_downloads) do
      Array.new(days) do |i|
        { date: Time.zone.parse("2014-07-#{i + 1}"), count: i + 1 }
      end.reverse
    end

    before do
      expect_any_instance_of(Rubygem).to receive(:daily_downloads).and_return(daily_downloads)
    end

    it "returns weekly downloads" do
      expect(weekly_downloads).to eq [
        { date: Time.zone.parse("2014-07-14"), count: 77 },
        { date: Time.zone.parse("2014-07-07"), count: 28 }
      ]
    end

    context "when last week is not 7 days" do
      let(:days) { 13 }

      it "returns weekly downloads" do
        expect(weekly_downloads).to eq [
          { date: Time.zone.parse("2014-07-13"), count: 70 },
          { date: Time.zone.parse("2014-07-06"), count: 21 }
        ]
      end
    end
  end
end
