-- COVID-19 DATA EXPLORATION PORTFOLIO PROJECT
-- Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Data Type Handling

----------------------------------------------------------------------------------------------------
-- 1. INITIAL DATA EXPLORATION
----------------------------------------------------------------------------------------------------

-- View entire CovidDeaths table with logical ordering
SELECT * 
FROM Potfolio_Project..CovidDeaths
ORDER BY 3,4;  -- Order by Location, Date

-- View entire CovidVaccinations table with logical ordering
SELECT * 
FROM Potfolio_Project..CovidVaccinations
ORDER BY 3,4;  -- Order by Location, Date

-- Basic data snapshot with key metrics
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Potfolio_Project..CovidDeaths
ORDER BY 1,2;  -- Order by Location, Date

----------------------------------------------------------------------------------------------------
-- 2. COUNTRY-SPECIFIC ANALYSIS
----------------------------------------------------------------------------------------------------

-- Case Fatality Rate in Egypt (Death Percentage of Confirmed Cases)
SELECT 
    Location, 
    date,
    total_cases,
    total_deaths,
    (total_deaths/NULLIF(total_cases,0))*100 AS death_percentage  -- Handle division by zero
FROM Potfolio_Project..CovidDeaths
WHERE location LIKE '%Egypt%'
    AND continent IS NOT NULL  -- Exclude continental aggregates
ORDER BY 1,2;

-- Infection Rate in Egypt (% of Population Infected)
SELECT 
    Location, 
    date,
    population,
    total_cases,
    (total_cases/NULLIF(population,0))*100 AS infection_rate
FROM Potfolio_Project..CovidDeaths
WHERE location LIKE '%Egypt%'
    AND continent IS NOT NULL
ORDER BY 1,2;

----------------------------------------------------------------------------------------------------
-- 3. GLOBAL INFECTION ANALYSIS
----------------------------------------------------------------------------------------------------

-- Countries with Highest Infection Rates Compared to Population
SELECT 
    Location,
    population,
    MAX(total_cases) AS peak_infection_count,
    MAX((total_cases/NULLIF(population,0)))*100 AS population_infection_percent
FROM Potfolio_Project..CovidDeaths
GROUP BY population, Location
ORDER BY population_infection_percent DESC;

----------------------------------------------------------------------------------------------------
-- 4. MORTALITY ANALYSIS
----------------------------------------------------------------------------------------------------

-- Countries with Highest Absolute Death Count
SELECT 
    Location,
    population,
    MAX(CAST(total_deaths AS INT)) AS total_death_count,
    MAX((total_deaths/NULLIF(population,0)))*100 AS population_death_percent
FROM Potfolio_Project..CovidDeaths
WHERE continent IS NOT NULL  -- Exclude continental aggregates
GROUP BY population, Location
ORDER BY total_death_count DESC;

-- Continental Death Analysis (Proper Method)
SELECT 
    Location,
    MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM Potfolio_Project..CovidDeaths
WHERE continent IS NULL  -- Select continental aggregates
    AND Location NOT IN ('World', 'European Union', 'International')  -- Exclude special groupings
GROUP BY Location
ORDER BY total_death_count DESC;

----------------------------------------------------------------------------------------------------
-- 5. GLOBAL TRENDS
----------------------------------------------------------------------------------------------------

-- Daily Global COVID Metrics
SELECT  
    date,
    SUM(new_cases) AS global_cases,
    SUM(CAST(new_deaths AS INT)) AS global_deaths,
    (SUM(CAST(new_deaths AS INT))/NULLIF(SUM(new_cases),0))*100 AS global_death_percent
FROM Potfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
    AND new_cases > 0  -- Exclude days without new cases
GROUP BY date
ORDER BY date;

-- Aggregate Global Totals
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    (SUM(CAST(new_deaths AS INT))/NULLIF(SUM(new_cases),0))*100 AS global_death_percent
FROM Potfolio_Project..CovidDeaths
WHERE continent IS NOT NULL;

----------------------------------------------------------------------------------------------------
-- 6. VACCINATION ANALYSIS
----------------------------------------------------------------------------------------------------

-- Population vs Vaccination Progress (CTE Method)
WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS (
    SELECT
        dea.continent,
        dea.location,
        CONVERT(DATE, dea.date),  -- Ensure date format consistency
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(ISNULL(vac.new_vaccinations,0) AS BIGINT))  -- Handle large numbers and NULLs
            OVER (PARTITION BY dea.location 
                ORDER BY dea.location, dea.date) AS rolling_vaccinations
    FROM Potfolio_Project..CovidVaccinations vac
    JOIN Potfolio_Project..CovidDeaths dea
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
    (rolling_vaccinations/NULLIF(population,0))*100 AS vaccination_percent
FROM PopVsVac;

----------------------------------------------------------------------------------------------------
-- 7. TEMP TABLE FOR VACCINATION ANALYSIS
----------------------------------------------------------------------------------------------------

-- Create Temporary Table for Vaccination Data Processing
DROP TABLE IF EXISTS #PopulationVaccinationStats;
CREATE TABLE #PopulationVaccinationStats (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_vaccinations NUMERIC
);

INSERT INTO #PopulationVaccinationStats
SELECT
    dea.continent,
    dea.location,
    CONVERT(DATE, dea.date),
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations,0) AS BIGINT))
        OVER (PARTITION BY dea.location 
            ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM Potfolio_Project..CovidVaccinations vac
JOIN Potfolio_Project..CovidDeaths dea
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Query from Temp Table with Vaccination Percentage
SELECT *,
    (rolling_vaccinations/NULLIF(population,0))*100 AS vaccination_percent
FROM #PopulationVaccinationStats;




----------------------------------------------------------------------------------------------------
-- 8. TEMPORAL TREND ANALYSIS
----------------------------------------------------------------------------------------------------

-- Monthly Case Growth Rate by Country
SELECT
    Location,
    YEAR(date) AS year,
    MONTH(date) AS month,
    SUM(new_cases) AS monthly_cases,
    LAG(SUM(new_cases)) OVER (PARTITION BY Location ORDER BY YEAR(date), MONTH(date)) AS prev_month_cases,
    (SUM(new_cases) - LAG(SUM(new_cases)) OVER (PARTITION BY Location ORDER BY YEAR(date), MONTH(date)))
    / NULLIF(LAG(SUM(new_cases)) OVER (PARTITION BY Location ORDER BY YEAR(date), MONTH(date)),0) * 100 AS growth_rate
FROM Potfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, YEAR(date), MONTH(date)
ORDER BY Location, year, month;

----------------------------------------------------------------------------------------------------
-- 9. VACCINATION MILESTONES
----------------------------------------------------------------------------------------------------

-- Days to Reach Vaccination Thresholds (10%, 25%, 50%)
WITH VaccinationProgress AS (
    SELECT
        dea.location,
        dea.date,
        dea.population,
        MAX(vac.people_fully_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations,
        (MAX(vac.people_fully_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.date) / dea.population) * 100 AS vaccinated_pct
    FROM Potfolio_Project..CovidDeaths dea
    JOIN Potfolio_Project..CovidVaccinations vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT 
    location,
    MIN(CASE WHEN vaccinated_pct >= 10 THEN date END) AS date_10pct,
    MIN(CASE WHEN vaccinated_pct >= 25 THEN date END) AS date_25pct,
    MIN(CASE WHEN vaccinated_pct >= 50 THEN date END) AS date_50pct
FROM VaccinationProgress
GROUP BY location
ORDER BY location;

----------------------------------------------------------------------------------------------------
-- 10. HEALTHCARE CAPACITY ANALYSIS
----------------------------------------------------------------------------------------------------

-- Hospital Bed Availability vs COVID Severity
SELECT
    dea.location,
    dea.population,
    MAX(vac.hospital_beds_per_thousand) AS beds_per_thousand,
    MAX(dea.total_cases_per_million) AS cases_per_million,
    MAX(dea.total_deaths_per_million) AS deaths_per_million,
    MAX(dea.icu_patients_per_million) AS icu_patients_per_million
FROM Potfolio_Project..CovidDeaths dea
JOIN Potfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY beds_per_thousand DESC;

----------------------------------------------------------------------------------------------------
-- 11. TESTING EFFECTIVENESS (FIXED SYNTAX)
----------------------------------------------------------------------------------------------------

-- Test Positivity Rate Over Time with Safe Conversions
SELECT
    dea.location,
    dea.date,
    TRY_CAST(vac.total_tests AS BIGINT) AS total_tests,  -- Handle large numbers
    TRY_CAST(dea.total_cases AS BIGINT) AS total_cases,
    CASE 
        WHEN TRY_CAST(vac.total_tests AS BIGINT) > 0 
        THEN (TRY_CAST(dea.total_cases AS FLOAT) * 100.0 
             / NULLIF(TRY_CAST(vac.total_tests AS FLOAT),0))  -- Added missing parenthesis
        ELSE NULL 
    END AS positivity_rate,
    TRY_CAST(vac.tests_per_case AS FLOAT) AS tests_per_case
FROM Potfolio_Project..CovidDeaths dea
JOIN Potfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    AND TRY_CAST(vac.total_tests AS BIGINT) > 0  -- Ensure valid numeric values
    AND TRY_CAST(dea.total_cases AS BIGINT) IS NOT NULL  -- Filter invalid case numbers
ORDER BY location, date;

----------------------------------------------------------------------------------------------------
-- 12. VACCINE BRAND ANALYSIS (CORRECTED)
----------------------------------------------------------------------------------------------------

-- Vaccination Type Analysis (Fallback)
SELECT
    location,
    MAX(total_vaccinations) AS total_vaccinations,
    MAX(people_vaccinated) AS people_vaccinated,
    MAX(people_fully_vaccinated) AS fully_vaccinated,
    MAX(total_boosters) AS booster_doses
FROM Potfolio_Project..CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_vaccinations DESC;
----------------------------------------------------------------------------------------------------
-- 13. STRINGENCY INDEX IMPACT
----------------------------------------------------------------------------------------------------

-- Government Response vs Case Growth
SELECT
    dea.location,
    dea.date,
    vac.stringency_index,
    dea.new_cases_per_million,
    AVG(dea.new_cases_per_million) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS rolling_avg_cases
FROM Potfolio_Project..CovidDeaths dea
JOIN Potfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

----------------------------------------------------------------------------------------------------
-- 14. DEMOGRAPHIC RISK FACTORS (OPTIMIZED)
----------------------------------------------------------------------------------------------------

WITH LatestDemographics AS (
    SELECT DISTINCT
        location,
        LAST_VALUE(median_age) OVER (
            PARTITION BY location 
            ORDER BY date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS median_age,
        LAST_VALUE(aged_65_older) OVER (
            PARTITION BY location 
            ORDER BY date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS aged_65_older,
        LAST_VALUE(aged_70_older) OVER (
            PARTITION BY location 
            ORDER BY date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS aged_70_older
    FROM Potfolio_Project..CovidVaccinations
    WHERE continent IS NOT NULL
),
DeathStats AS (
    SELECT
        location,
        MAX(total_deaths_per_million) AS deaths_per_million
    FROM Potfolio_Project..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY location
)
SELECT
    d.location,
    ld.median_age,
    ld.aged_65_older,
    ld.aged_70_older,
    d.deaths_per_million,
    MAX(vac.total_vaccinations_per_hundred) AS vaccinations_per_hundred
FROM DeathStats d
JOIN LatestDemographics ld ON d.location = ld.location
JOIN Potfolio_Project..CovidVaccinations vac 
    ON d.location = vac.location
    AND vac.date BETWEEN '2021-01-01' AND '2023-12-31'  -- Restrict date range
GROUP BY d.location, ld.median_age, ld.aged_65_older, ld.aged_70_older, d.deaths_per_million
ORDER BY d.deaths_per_million DESC;

----------------------------------------------------------------------------------------------------
-- 15. ECONOMIC FACTORS (OPTIMIZED)
----------------------------------------------------------------------------------------------------

WITH EconomicData AS (
    SELECT DISTINCT
        location,
        LAST_VALUE(gdp_per_capita) OVER (
            PARTITION BY location 
            ORDER BY date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS gdp_per_capita
    FROM Potfolio_Project..CovidVaccinations
    WHERE continent IS NOT NULL
),
VaccinationStats AS (
    SELECT
        location,
        MAX(total_vaccinations_per_hundred) AS vaccinations_per_hundred
    FROM Potfolio_Project..CovidVaccinations
    GROUP BY location
)
SELECT
    ed.location,
    ed.gdp_per_capita,
    vs.vaccinations_per_hundred,
    MAX(dea.total_deaths_per_million) AS deaths_per_million
FROM EconomicData ed
JOIN VaccinationStats vs ON ed.location = vs.location
JOIN Potfolio_Project..CovidDeaths dea 
    ON ed.location = dea.location
    AND dea.date BETWEEN '2020-01-01' AND '2023-12-31'  -- Limit date scope
GROUP BY ed.location, ed.gdp_per_capita, vs.vaccinations_per_hundred
ORDER BY ed.gdp_per_capita DESC;
----------------------------------------------------------------------------------------------------
-- 16. PEAK ANALYSIS
----------------------------------------------------------------------------------------------------

-- Peak Infection Periods by Country
WITH InfectionPeaks AS (
    SELECT
        location,
        date,
        new_cases,
        RANK() OVER (PARTITION BY location ORDER BY new_cases DESC) AS peak_rank
    FROM Potfolio_Project..CovidDeaths
    WHERE continent IS NOT NULL
)
SELECT
    location,
    date AS peak_date,
    new_cases AS peak_cases
FROM InfectionPeaks
WHERE peak_rank = 1
ORDER BY peak_cases DESC;

----------------------------------------------------------------------------------------------------
-- 17. VACCINATION BOOSTER ANALYSIS (FIXED)
----------------------------------------------------------------------------------------------------

-- Booster Dose Progress Over Time
SELECT
    dea.location,
    dea.date,
    TRY_CAST(vac.total_boosters AS FLOAT) AS total_boosters,
    TRY_CAST(vac.total_vaccinations AS FLOAT) AS total_vaccinations,
    (TRY_CAST(vac.total_boosters AS FLOAT) / NULLIF(TRY_CAST(vac.total_vaccinations AS FLOAT), 0)) * 100 AS booster_rate
FROM Potfolio_Project..CovidDeaths dea
JOIN Potfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    AND vac.total_boosters IS NOT NULL
ORDER BY location, date;


