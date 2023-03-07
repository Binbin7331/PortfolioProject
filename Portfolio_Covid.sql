SELECT *
FROM Portfolio..CovidDeaths$
--Where continent is not null
ORDER BY 3,4

-- Select data that we are going to use 
SELECT
location, 
date,
total_cases,
new_cases,
total_deaths,
population
FROM Portfolio..CovidDeaths$
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Show likelihood if you have covid in your country
SELECT
location,date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as death_percentage

FROM Portfolio..CovidDeaths$
WHERE location like '%Thai%'
order by 1,2

-- Looking at Total cases VS Population
-- Infection rate in your country
SELECT
location,date,
Population,
total_cases,
(total_cases/Population)*100 as Infected_percentage

FROM Portfolio..CovidDeaths$
WHERE location like '%Thai%'
order by 1,2

--Looking at countries with highest infection rate


SELECT
location,
population,
MAX(total_cases) as HightestInfectionCount,
MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM Portfolio..CovidDeaths$
GROUP BY location,population
order by PercentagePopulationInfected DESC

--Showing countries with highest death count per population
SELECT
location,
population,
MAX(cast(total_deaths as int)) as HighestDeathCount,
MAX((total_deaths/population)*100) as DeathPercentage
FROM Portfolio..CovidDeaths$
Where continent is not null
GROUP BY location,population
Order by HighestDeathCount DESC

--Break down by continent
SELECT

continent,
MAX(cast(total_deaths as int)) as HighestDeathCount
FROM Portfolio..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Showing continents with highest death counts
SELECT
continent,
MAX(cast(total_deaths as int)) as HighestDeathCount,
MAX((total_deaths/population)*100) as DeathPercentage
FROM Portfolio..CovidDeaths$
Where continent is not null
GROUP BY continent
Order by HighestDeathCount DESC


--Global numbers

SELECT 
date,
sum(new_cases) as total_new_cases,
sum(cast(new_deaths as int)) as total_new_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_per_newcases
FROM Portfolio..CovidDeaths$
where continent is not null
GROUP BY date
order by 1,2

-- Join Vaccination table

SELECT
*
FROM Portfolio..CovidVaccination$ cv
JOIN Portfolio..CovidDeaths$ cd
on cv.location = cd.location
and cv.date = cd.date

--Looking at Total Population vs Vaccination

SELECT
cd.location,
cd.date,
cd.population,
cv.new_vaccinations
FROM Portfolio..CovidVaccination$ cv
JOIN Portfolio..CovidDeaths$ cd
on cv.location = cd.location
and cv.date = cd.date
order by cd.location,cd.date

--Add up vaccination each day

With PopvsVac ( continent,location,Date,Population,new_vaccinations,RollingVac)
as(
SELECT
cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(convert(float,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,cd.date) as RollingVac
FROM Portfolio..CovidVaccination$ cv
JOIN Portfolio..CovidDeaths$ cd
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null -- TO GET ONLY LOCATION THAT IS NOT FILL AS CONTINENT
--order by cd.location,cd.date
)
SELECT *,(RollingVac/Population)*100
FROM PopvsVac
order by 2,3

-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
SELECT
cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(convert(float,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,cd.date) as RollingVac
FROM Portfolio..CovidVaccination$ cv
JOIN Portfolio..CovidDeaths$ cd
	on cv.location = cd.location
	and cv.date = cd.date
where cd.continent is not null -- TO GET ONLY LOCATION THAT IS NOT FILL AS CONTINENT
--order by cd.location,cd.date