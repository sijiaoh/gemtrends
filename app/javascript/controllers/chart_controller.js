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
    const weeklyDownloadsByName = this.dataValue;
    // Reverse the order of the data so that the chart starts at the left.
    Object.values(weeklyDownloadsByName).map((weeklyDownloads) =>
      weeklyDownloads.reverse(),
    );

    const datesArray = Object.values(weeklyDownloadsByName).map(
      (weeklyDownloads) => weeklyDownloads.map(({ date }) => date),
    );
    const longestDates = datesArray.sort((a, b) => b.length - a.length)[0];
    const horizontalAxisLabels = longestDates;

    const allColorsCount = 11;
    const allColors = palette("cb-Paired", allColorsCount);
    // Use red to first color.
    const colorIndexOffset = 2;

    const datasets = Object.entries(weeklyDownloadsByName).map(
      ([name, weeklyDownloads], index) => {
        const color =
          allColors[((index + colorIndexOffset) * 2) % allColorsCount];

        // Fill in nulls for dates that don't have data.
        const filler = Array(
          horizontalAxisLabels.length - weeklyDownloads.length,
        ).fill(null);

        const data = [...filler, ...weeklyDownloads.map(({ count }) => count)];

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
