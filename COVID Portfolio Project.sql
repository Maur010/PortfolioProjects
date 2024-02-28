/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT 
	*
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	3,4

-- Select Data that we are going to be starting with

SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM 
	PortfolioProject..CovidDeaths
ORDER BY 
	1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Mexico
SELECT 
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	location like '%Mexico%'
ORDER BY 
	1,2

-- Total Cases vs Population
-- Show what percentage of population got Covid
SELECT 
	Location, date,population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
ORDER BY 
	1,2


-- Countries with Highest Infection Rate compared to Population
SELECT 
	Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM 
	PortfolioProject..CovidDeaths
GROUP BY 
	location, population
ORDER BY 
	PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
SELECT 
	Location, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	TotalDeathCount desc

-- Showing continents with the highest death count per population
SELECT 
	location, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NULL
GROUP BY 
	location
ORDER BY 
	TotalDeathCount desc

-- Global numbers
SELECT 
	 date, SUM(new_cases) AS totalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY date
ORDER BY 
	1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
	JOIN 
		PortfolioProject..CovidVaccinations$ vac
		ON
			dea.location = vac.location
			AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 
	2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
	SELECT
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM 
		PortfolioProject..CovidDeaths dea
		JOIN 
			PortfolioProject..CovidVaccinations$ vac
			ON
				dea.location = vac.location
				AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 
	--	2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric

)
INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
	JOIN 
		PortfolioProject..CovidVaccinations$ vac
		ON
			dea.location = vac.location
			AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
	JOIN 
		PortfolioProject..CovidVaccinations$ vac
		ON
			dea.location = vac.location
			AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

