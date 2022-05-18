--Selecting the data to be use for the project
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Looking at Total cases vs Total Deaths
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Death Percentage in specific countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%canada%'
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%ghana%'
ORDER BY 1,2

--Looking at percentage of Population Infected
SELECT location, date, population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%ghana%'
ORDER BY 1,2


SELECT location, population,MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


SELECT location, population,MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%ghana%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at the total death count
SELECT location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC


SELECT continent, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--looking infected people in relation to their income
SELECT location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%income%'
AND continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--looking Total death per continent
SELECT continent, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global figures
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(total_deaths AS numeric)) AS TotalDeaths, SUM(CAST(total_deaths AS numeric)) /SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



SELECT SUM(new_cases) AS TotalCases, SUM(CAST(total_deaths AS numeric)) AS TotalDeaths, SUM(CAST(total_deaths AS numeric)) /SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC,vac.new_vaccinations)) OVER (PARTITION BY dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


--CTE

WITH PopvsVac (continent, location,Date,population,new_vaccination,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVacinnated
CREATE TABLE #PercentagePopulationVacinnated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)

INSERT INTO #PercentagePopulationVacinnated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


--CREATING VIEW to store data for later visualization


CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3