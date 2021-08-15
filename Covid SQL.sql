SELECT *
FROM coviddeath
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM coviddeath
WHERE location like "%state%"
ORDER BY 1,2


-- Total Cases vs population
SELECT location,date,total_cases,population,(total_cases/population)*100 AS infected_percentage
FROM coviddeath
-- WHERE location like "%state%"
ORDER BY 1,2



-- Countries with Highest infection rate Compared to Population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)*100) AS infected_percentage
FROM coviddeath
-- WHERE location like "%state%"
GROUP BY location,population
ORDER BY infected_percentage DESC



-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeath
-- WHERE location like "%state%"
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continent With the Highest death Count

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeath
-- WHERE location like "%state%"
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Global Numbers
SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths,SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases) AS DeathPercentage-- ,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM coviddeath
-- WHERE location like "%state%"
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2




-- Total Population vs Vaccination

SELECT cd.continent,cd.location,cd.date,cv.population,cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER ( PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated

FROM coviddeath cd
JOIN covidvaccination cv
	ON cd.location=cv.location
    AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3



-- USE CTE

WITH POPvsVAC (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
	SELECT cd.continent,cd.location,cd.date,cv.population,cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER ( PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated

	FROM coviddeath cd
	JOIN covidvaccination cv
		ON cd.location=cv.location
		AND cd.date=cv.date
	WHERE cd.continent IS NOT NULL
	-- ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM POPvsVAC




-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent,cd.location,cd.date,cv.population,cv.new_vaccinations,
SUM(CONVERT(cv.new_vaccinations,INT)) OVER ( PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
	
FROM coviddeath cd
JOIN covidvaccination cv
	ON cd.location=cv.location
	AND cd.date=cv.date
-- WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated



-- Creating View to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent,cd.location,cd.date,cv.population,cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER ( PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
	
FROM coviddeath cd
JOIN covidvaccination cv
	ON cd.location=cv.location
	AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3
