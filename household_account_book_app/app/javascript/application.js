import "@hotwired/turbo-rails";
import "controllers";
import "chartkick";
import "Chart.bundle";

async function fetchIncomesData() {
  try {
    const response = await fetch("/households/collecting_incomes_grath_data");
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    const data = await response.json();

    if (data.status === "completed") {
      console.log("収集完了:", data);

      const AddedChartThisYearContainer = document.querySelector(
        ".grath-income-this-year-content"
      );
      AddedChartThisYearContainer.innerHTML = data.html_year;
      const scriptsThisYear =
        AddedChartThisYearContainer.querySelectorAll("script");
      scriptsThisYear.forEach((script) => {
        const newScript = document.createElement("script");
        newScript.textContent = script.innerHTML;
        document.body.appendChild(newScript);
        document.body.removeChild(newScript);
      });

      const AddedChartThisMonthContainer = document.querySelector(
        ".grath-income-this-month-content"
      );
      AddedChartThisMonthContainer.innerHTML = data.html_month;
      const scriptsThisMonth =
        AddedChartThisMonthContainer.querySelectorAll("script");
      scriptsThisMonth.forEach((script) => {
        const newScript = document.createElement("script");
        newScript.textContent = script.innerHTML;
        document.body.appendChild(newScript);
        document.body.removeChild(newScript);
      });
    } else if (data.status === "in_progress") {
      console.log("データ収集中。数秒後に再試行します...");
      setTimeout(fetchIncomesData, 10000);
    } else {
      console.warn("未定義のステータス:", data.status);
    }
  } catch (error) {
    console.error("エラー:", error.message);
  }
}

fetchIncomesData();
