

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- looking at total cases and total deaths in Vietnam

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
Where location like 'vietnam'
ORDER BY 1,2

-- looking at total cases and POPULATION in Vietnam

SELECT location, date, total_cases, population, (total_cases/population)*100 CasePercentage
FROM CovidDeaths
Where location like 'vietnam'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population 

SELECT location, population,  max(total_cases) as  Highest_Infection , max((total_cases/population))*100 Percent_Population_Infected
FROM CovidDeaths
group by location, population
ORDER BY Percent_Population_Infected DESC

--  Countries with Highest Death Rate compared to Population 

SELECT location, population, max(cast(total_deaths as int)) as Total_deaths, (max(cast(total_deaths as int))/population)*100 AS Percent_Population
FROM CovidDeaths
group by location, population
ORDER BY Percent_Population DESC


-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as Total_deaths
from CovidDeaths
where continent is not null
group by continent
order by Total_deaths DESC

--  GLOBAL NUMBERS

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

-- Looking at total population and vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
SUM(CONVERT(INT, VA.new_vaccinations)) OVER (PARTITION BY DE.location ORDER BY DE.location, DE.date) AS Rolling_people_vaccination
FROM CovidDeaths DE
JOIN CovidVaccinations VA
	ON DE.continent = VA.continent
	AND DE.date = VA.date
WHERE DE.continent IS NOT NULL AND VA.new_vaccinations IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH RPV (continent,location,date,population,new_vaccinations,Rolling_people_vaccinated ) 
AS ( 
		SELECT DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
SUM(CONVERT(INT, VA.new_vaccinations)) OVER (PARTITION BY DE.location ORDER BY DE.location, DE.date) AS Rolling_people_vaccinated
FROM CovidDeaths DE
JOIN CovidVaccinations VA
	ON DE.continent = VA.continent
	AND DE.date = VA.date
WHERE DE.continent IS NOT NULL AND VA.new_vaccinations IS NOT NULL
	)
SELECT *, (Rolling_people_vaccinated/population)*100 Percentage_Rolling_people_vaccinated
FROM RPV

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	Rolling_people_vaccinated numeric
	)
INSERT INTO #PercentPopulationVaccinated
SELECT DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
SUM(CONVERT(INT, VA.new_vaccinations)) OVER (PARTITION BY DE.location ORDER BY DE.location, DE.date) AS Rolling_people_vaccinated
FROM CovidDeaths DE
JOIN CovidVaccinations VA
	ON DE.continent = VA.continent
	AND DE.date = VA.date
WHERE DE.continent IS NOT NULL AND VA.new_vaccinations IS NOT NULL

SELECT *, (Rolling_people_vaccinated/population)*100 Percentage_Rolling_people_vaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
SUM(CONVERT(INT, VA.new_vaccinations)) OVER (PARTITION BY DE.location ORDER BY DE.location, DE.date) AS Rolling_people_vaccinated
FROM CovidDeaths DE
JOIN CovidVaccinations VA
	ON DE.continent = VA.continent
	AND DE.date = VA.date
WHERE DE.continent IS NOT NULL AND VA.new_vaccinations IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
WHERE continent = 'ASIA'
