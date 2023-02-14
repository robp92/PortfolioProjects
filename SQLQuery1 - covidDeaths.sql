SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,ROUND(MAX((total_cases/population)) *100,2) AS infection_ratio
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, Population
ORDER BY 4 DESC

--Showing countries with highest cases (as % of total population)

SELECT Location, Population, MAX(CAST(total_deaths AS INTEGER)) AS TotalDeathCount,ROUND(MAX((total_deaths/population)) *100,2) AS DeathsPerPopulation
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY 4 DESC

--Showing countries with death rate (as % of total population)

SELECT continent, MAX(CAST(total_deaths AS INTEGER)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

--Breaking things down by continent

SELECT location, MAX(CAST(total_deaths AS INTEGER)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;

-- GLOBAL NUMBERS (ALL TIME)

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS NewDeathRatio
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total population vs vaccinations

--Common table expression (CTE)

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ROUND((rolling_vaccinations/Population)*100,2) AS VaccinationRate
FROM PopVsVac

-- Temp table

-- add the below line of code, if you want to make alterations to your temp table syntax
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
rolling_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ROUND((rolling_vaccinations/Population)*100,2) AS VaccinationRate
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

DROP View if exists PercentPopulationVaccinated
GO

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
GO

-- Utilising the previously created View
SELECT * 
FROM PercentPopulationVaccinated