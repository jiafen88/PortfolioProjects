/* Queries used for Tableau Project*/

-- Table 1.
Select SUM(new_cases) as total_cases,
    SUM(cast(new_deaths as int)) as total_deaths,
    SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortProjects..CovidDeaths
where continent is not null
order by 1,2

-- Table 2.
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortProjects..CovidDeaths
where isnull(continent, '') <> ''
Group by location
order by TotalDeathCount desc


-- Table 3.
Select Location, Population,
    MAX(total_cases) as HighestInfectionCount,
    Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Table 4.
Select Location,
    Population,date,
    MAX(total_cases) as HighestInfectionCount,
    Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


--Table 5.
Select death.continent,
    death.location, death.date,
    death.population,
    MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From PortProjects..CovidDeaths death
Join PortProjects..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
group by death.continent, death.location, death.date, death.population
order by 1,2,3


-- Table 6.
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
    Select death.continent,
           death.location,
           death.date,
           death.population,
           vac.new_vaccinations,
           SUM(vac.new_vaccinations) OVER (Partition by death.Location Order by death.Date) as RollingPeopleVaccinated
    From PortProjects..CovidDeaths death
    Join PortProjects..CovidVaccinations vac
	    On death.location = vac.location
	    and death.date = vac.date
    where death.continent is not null
)

Select *,
    (RollingPeopleVaccinated/nullif(Population, 0))*100 as PercentPeopleVaccinated
From PopvsVac