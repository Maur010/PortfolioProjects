SELECT 
	*
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	3,4


SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM 
	PortfolioProject..CovidDeaths
ORDER BY 
	1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	location like '%Mexico%'
ORDER BY 
	1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
SELECT 
	Location, date,population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
--WHERE location like '%Mexico%'
ORDER BY 
	1,2


-- Looking at countries with Highest Infection Rate compared to Population.
SELECT 
	Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM 
	PortfolioProject..CovidDeaths
GROUP BY 
	location, population
ORDER BY 
	PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
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

-- Showing Countries with Highest Death Count per Continent
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


-- Looking at Total Population vs Vaccionations
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

-- USE CTE
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

-- Temp table

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
--WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-----------------------------------


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

