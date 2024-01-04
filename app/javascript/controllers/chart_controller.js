import { Controller } from "@hotwired/stimulus";
import { Chart, registerables } from "chart.js";
import palette from "google-palette";

Chart.register(...registerables);

export default class extends Controller {
  static targets = ["chart"];
  static values = {
    // Chart#to_chart_view_json
    // { name: [{ date: "2021-01-01", count: 1 }] }
    data: Object,
  };

  connect() {
    const weeklyTotalDownloadsByName = this.dataValue;
    // Reverse the order of the data so that the chart starts at the left.
    Object.values(weeklyTotalDownloadsByName).map((weeklyTotalDownloads) =>
      weeklyTotalDownloads.reverse(),
    );

    const datesArray = Object.values(weeklyTotalDownloadsByName).map(
      (weeklyTotalDownloads) => weeklyTotalDownloads.map(({ date }) => date),
    );
    const longestDates = datesArray.sort((a, b) => b.length - a.length)[0];
    const horizontalAxisLabels = longestDates;

    const allColorsCount = 11;
    const allColors = palette("cb-Paired", allColorsCount);
    // Use red to first color.
    const colorIndexOffset = 2;

    const datasets = Object.entries(weeklyTotalDownloadsByName).map(
      ([name, weeklyTotalDownloads], index) => {
        const color =
          allColors[((index + colorIndexOffset) * 2) % allColorsCount];

        // Fill in nulls for dates that don't have data.
        const filler = Array(
          horizontalAxisLabels.length - weeklyTotalDownloads.length,
        ).fill(null);

        const data = [
          ...filler,
          ...weeklyTotalDownloads.map(({ total_downloads }) => total_downloads),
        ];

        return {
          label: name,
          data,
          tension: 0.5,
          backgroundColor: `#${color}`,
          borderColor: `#${color}`,
          pointRadius: 0,
          hoverRadius: 6,
        };
      },
    );

    const config = {
      type: "line",
      data: { labels: horizontalAxisLabels, datasets },
      options: {
        interaction: {
          mode: "index",
          intersect: false,
        },
        scales: {
          y: {
            beginAtZero: true,
          },
          x: {
            ticks: {
              maxRotation: 30,
            },
          },
        },
      },
    };
    new Chart(this.chartTarget, config);
  }
}
