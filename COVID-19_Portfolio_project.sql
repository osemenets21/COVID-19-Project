-- select a few columns for chacking information
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2


-- shows likelihood of dying if you contract COVID-19 in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_precentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ukraine'
order by 1, 2


-- looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as cases_precentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ukraine'
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as procent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY population, location
order by  procent_population_infected desc


-- showing countries with Highest Deadth Count per Population

SELECT location,  MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
order by total_death_count desc


-- showing continents with the highest death count per population

SELECT continent,  MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by total_death_count desc

-- global numbers of cases across the world by day
 
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- global numbers of cases across the world for all time

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2



-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vac
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--Use CTE

WITH PopVsVacc (continent, location, date, population, new_vaccinations, rolling_people_vac)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS rolling_people_vac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (rolling_people_vac/population)*100
FROM PopVsVacc

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



