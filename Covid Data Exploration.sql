--Change table column(s) data types:
--ALTER TABLE dbo.covid_vaccinations
--ALTER COLUMN new_vaccinations FLOAT



-- Select the data that we are going to be using:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.covid_deaths
ORDER BY 1,2



-- Total cases vs. total deaths and calculate the % of people that have died from those that were reported infected:
-- Shows the likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM dbo.covid_deaths
--WHERE location LIKE '%States%'
ORDER BY 1,2



-- Total cases vs. Population
-- Shows % of population that contracted COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
FROM dbo.covid_deaths
--WHERE location LIKE '%States%'
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population Size

Select 
    Location, 
    Population, 
    MAX(total_cases) as HighestInfectionCount,  
    MAX((total_cases/population))*100 as PercentPopulationInfected
From dbo.covid_deaths
Group by Location, Population
Order by PercentPopulationInfected desc



-- Countries with Highest Death Count

Select 
    Location, 
    MAX(Total_deaths) as TotalDeathCount
From dbo.covid_deaths
Where continent is not null 
Group by Location
Order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select 
    continent, 
    MAX(Total_deaths) as TotalDeathCount
From dbo.covid_deaths
Where continent is not null 
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

-- Total Cases, Total Deaths, and Death %

Select 
    SUM(new_cases) as total_cases, 
    SUM(new_deaths) as total_deaths, 
    SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From dbo.covid_deaths
Where continent is not null 
--Group By date
Order by 1,2



-- Join both tables:

Select *
From dbo.covid_deaths as dea
Join dbo.covid_vaccinations as vac
    On dea.location = vac.location
    and dea.date = vac.date




-- Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- From dbo.covid_deaths as dea
-- Join dbo.covid_vaccinations as vac
--     On dea.location = vac.location
--     and dea.date = vac.date
-- Where dea.continent is not null 
-- Order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From dbo.covid_deaths as dea
Join dbo.covid_vaccinations as vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3



-- Total Population vs. Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.covid_deaths as dea
Join dbo.covid_vaccinations as vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3



-- Use CTE to calculate rolling % of population vaccinated:

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    From dbo.covid_deaths as dea
    Join dbo.covid_vaccinations as vac
        On dea.location = vac.location
        and dea.date = vac.date
    Where dea.continent is not null 
    --Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100 AS percentvaccinated
From PopvsVac
Order by 2,3



--TEMP Table

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

Insert Into #PercentPopulationVaccinated
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    From dbo.covid_deaths as dea
    Join dbo.covid_vaccinations as vac
        On dea.location = vac.location
        and dea.date = vac.date
    --Where dea.continent is not null 
    --Order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100 AS percentvaccinated
From #PercentPopulationVaccinated
Order by 2,3



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.covid_deaths as dea
Join dbo.covid_vaccinations as vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null 


