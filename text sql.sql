Select *
from covid.coviddeaths
where continent is not null AND continent <> ''
order by 3,4;

-- Select *
-- from covid.covidvaccinations
-- order by 3,4;
-- Select data use

Select Location, date, total_cases, new_cases, total_deaths, population
from covid.coviddeaths
where continent is not null AND continent <> ''
order by 1, 2;


-- Looking at Total Cases vs Total Deaths
Select ROW_NUMBER() over (order by location) as rownum, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid.coviddeaths
where location like '%state%' and continent is not null AND continent <> ''
order by 1, 2;

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid!!
Select ROW_NUMBER() over (order by location) as rownum, 
		Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from covid.coviddeaths
-- where location like '%state%'
order by 1, 2;

-- Looking at Countries with Highest Infection Rate comparte to Population
Select ROW_NUMBER() over (order by location) as rownum, 
		Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/Population)*100) as PercentPopulationInfected
from covid.coviddeaths
group by Location, Population
-- where location like '%state%'
order by PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population
Select ROW_NUMBER() over (order by max(total_deaths) DESC) as rownum, 
		Location, max(total_deaths) as TotalDeathCount
from covid.coviddeaths
where continent is not null AND continent <> ''
group by Location
order by TotalDeathCount DESC;

-- Showing Countries with Highest Death Count per Population
Select ROW_NUMBER() over (order by location) as rownum, 
		Population, total_deaths, max(total_deaths/population)*100 as PercentPopulationDead
from covid.coviddeaths
group by Location, Population
order by PercentPopulationInfected DESC;

-- LET's Break things down by Continent
Select ROW_NUMBER() over (order by max(total_deaths) DESC) as rownum, 
		Continent, max(total_deaths) as TotalDeathCount
from covid.coviddeaths
where continent is not null AND continent <> ''
group by Continent
order by TotalDeathCount DESC;

-- Global number by date
Select date, sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from coviddeaths
where continent is not null AND continent <> ''
group by date
order by date;

Select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from coviddeaths
where continent is not null AND continent <> ''
-- group by date
-- order by date;


-- Update Date column type in CovidVaccination
UPDATE covidvaccinations
SET date = STR_TO_DATE(date, '%c/%e/%Y');
alter table covidvaccinations
modify column date date;

-- Join 2 tables by Location and Date
-- Looking at Total Population vs Vaccinations (CTE)
With Rolling_PeopleVaccinated 
as (
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) over (partition by vac.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--     (RollingPeopleVaccinated/dea.population)*100
	from covid.coviddeaths dea
	join covid.covidvaccinations vac 
		on dea.location=vac.location 
		and dea.date=vac.date
	where dea.continent is not null AND dea.continent <> ''
	order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as VacvsPop
from Rolling_PeopleVaccinated;

alter
-- Create Temp Table
drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(
Continent varchar (50),
Location varchar (50),
Date date,
Population bigint,
new_vaccinations int,
RollingPeopleVaccinated numeric
);
Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) over (partition by vac.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--     (RollingPeopleVaccinated/dea.population)*100
	from covid.coviddeaths dea
	join covid.covidvaccinations vac 
		on dea.location=vac.location 
		and dea.date=vac.date;
-- 	where dea.continent is not null AND dea.continent <> ''
-- 	order by 2,3;

select *, (RollingPeopleVaccinated/population)*100 as VacvsPop
from PercentPopulationVaccinated;

-- Creating view to store data for later visualazations
Create view View_PercentPopulationVaccinated as
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) over (partition by vac.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--     (RollingPeopleVaccinated/dea.population)*100
	from covid.coviddeaths dea
	join covid.covidvaccinations vac 
		on dea.location=vac.location 
		and dea.date=vac.date
	where dea.continent is not null AND dea.continent <> ''
	order by 2,3;
