import "@hotwired/turbo-rails";
import "controllers";
import "chartkick";
import "Chart.bundle";
async function fetchIncomesData() {
  try {
    const response = await fetch("/households/collecting_incomes_graph_data");
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    const data = await response.json();

    if (data.status === "completed") {
      console.log("収集完了:", data);

      const AddedChartThisYearContainer = document.querySelector(
        ".graph-income-this-year-content"
      );
      AddedChartThisYearContainer.innerHTML = data.html_year;

      const AddedChartThisMonthContainer = document.querySelector(
        ".graph-income-this-month-content"
      );
      AddedChartThisMonthContainer.innerHTML = data.html_month;

      executeScriptsFromContainer(AddedChartThisYearContainer);
      executeScriptsFromContainer(AddedChartThisMonthContainer);
    } else if (data.status === "in_progress") {
      console.log("データ収集中。数秒後に再試行します...");
      setTimeout(() => fetchIncomesData(), 1000);
    } else {
      console.warn("未定義のステータス:", data.status);
    }
  } catch (error) {
    console.error("エラー:", error.message);
  }
}

function executeScriptsFromContainer(container) {
  const scripts = container.querySelectorAll("script");
  scripts.forEach((script) => {
    const newScript = document.createElement("script");
    newScript.textContent = script.innerHTML;
    document.body.appendChild(newScript);
    document.body.removeChild(newScript);
  });
}

document.addEventListener("turbo:load", function () {
  const currentUrl = window.location.pathname;
  if (currentUrl.includes("/households/income")) {
    fetchIncomesData();
  }
});
