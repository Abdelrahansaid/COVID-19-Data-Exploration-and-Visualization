# COVID-19 Data Exploration and Visualization

## Overview
This repository contains a comprehensive analysis of COVID-19 data using SQL for data exploration and Tableau for visualization. The project focuses on exploring various aspects of the pandemic, including infection rates, mortality rates, vaccination progress, healthcare capacity, and demographic/economic factors. It also includes an interactive Tableau dashboard for visual insights into global trends.

---

## Repository Details

### Owner
Abdelrahman Said  
[Tableau Profile](https://public.tableau.com/app/profile/abdelrahman.said2856/viz/COVID-19GlobalAnalysisDashboard/Story1)

### Repository Name
**COVID-19-Data-Exploration-and-Visualization**

### Description
This project provides a detailed analysis of COVID-19 data using SQL queries for data processing and Tableau for visualization. The SQL scripts explore key metrics such as case fatality rates, infection rates, vaccination milestones, and peak infection periods. The Tableau dashboard offers an interactive view of global trends, enabling users to analyze the impact of the pandemic across different countries and regions.

---

## Contents of the Repository

1. **SQL Script (`COVID19_Data_Exploration.sql`)**
   - A SQL script that performs extensive data exploration on two datasets: `CovidDeaths` and `CovidVaccinations`.
   - Key analyses include:
     - Case Fatality Rate and Infection Rate in Egypt.
     - Global infection and mortality trends.
     - Vaccination progress and milestones.
     - Healthcare capacity and testing effectiveness.
     - Demographic and economic risk factors.
   - Advanced SQL techniques used:
     - Joins
     - Common Table Expressions (CTEs)
     - Temporary Tables
     - Window Functions
     - Aggregate Functions
     - Data Type Handling

2. **Tableau Workbook (`COVID-19 Global Analysis Dashboard.twbx`)**
   - An interactive Tableau dashboard that visualizes the results of the SQL analysis.
   - Includes:
     - Global and country-specific trends.
     - Vaccination progress and booster dose rates.
     - Healthcare capacity metrics.
     - Economic and demographic correlations with pandemic outcomes.
   - Access the dashboard online: [Tableau Public Link](https://public.tableau.com/app/profile/abdelrahman.said2856/viz/COVID-19GlobalAnalysisDashboard/Story1)

---

## How to Use This Repository

### Prerequisites
- **SQL Server**: To run the SQL script, you need access to SQL Server or a compatible database system.
- **Tableau Desktop**: To open and modify the `.twbx` workbook, Tableau Desktop is required.
- **Datasets**: Ensure you have access to the `CovidDeaths` and `CovidVaccinations` datasets. These can be sourced from public repositories like [Our World in Data](https://ourworldindata.org/covid-deaths).

### Steps to Reproduce the Analysis
1. **Set Up the Database**:
   - Import the `CovidDeaths` and `CovidVaccinations` datasets into your SQL Server database.
   - Update the table names and schema in the SQL script if necessary.

2. **Run the SQL Script**:
   - Execute the `COVID19_Data_Exploration.sql` script in your SQL environment.
   - Review the results of each query to understand the data insights.

3. **Explore the Tableau Dashboard**:
   - Open the `COVID-19 Global Analysis Dashboard.twbx` file in Tableau Desktop.
   - Alternatively, view the dashboard online via the [Tableau Public Link](https://public.tableau.com/app/profile/abdelrahman.said2856/viz/COVID-19GlobalAnalysisDashboard/Story1).

---

## Key Insights from the Analysis

1. **Country-Specific Analysis**:
   - Examined case fatality rates and infection rates in Egypt.
   - Identified countries with the highest infection and mortality rates.

2. **Global Trends**:
   - Tracked daily and cumulative global cases and deaths.
   - Analyzed monthly case growth rates by country.

3. **Vaccination Progress**:
   - Monitored vaccination milestones (10%, 25%, 50% thresholds).
   - Evaluated booster dose rates and their impact.

4. **Healthcare Capacity**:
   - Correlated hospital bed availability with COVID-19 severity metrics.

5. **Demographic and Economic Factors**:
   - Explored the relationship between age demographics, GDP per capita, and pandemic outcomes.

---

## Acknowledgments

- **Data Source**: [Our World in Data](https://ourworldindata.org/covid-deaths)
- **Tools Used**:
  - SQL Server for data exploration.
  - Tableau for visualization.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

For questions or feedback, feel free to reach out:  
- Email: [Your Email Address]  
- LinkedIn: [Your LinkedIn Profile]  
- Tableau: [Your Tableau Profile](https://public.tableau.com/app/profile/abdelrahman.said2856)

---

Let me know if you'd like to make any changes or add more details!
