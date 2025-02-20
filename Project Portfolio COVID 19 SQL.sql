--PROJECT PORTFOLIO SQL - COVID 19

SELECT *
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project].dbo.CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to use:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract Covid in ones country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location LIKE '%Germany%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- What % of Population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 
AS PopulationPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
ORDER BY 1,2


-- Looking at Countries w7 highest Infection Rate compard to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
		MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries w/ highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC
-- not fully accurate, NA only includes US, not Canada nor Mexico, for example


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
				SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT *
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated