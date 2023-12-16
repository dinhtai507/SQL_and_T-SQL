use PortfolioProject
--
select *
from PortfolioProject..CovidDeaths
order by 3, 4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%state%'
order by 1, 2 

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
select location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%state%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount,
	max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%state%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Country with highest death count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%state%'
group by location
order by TotalDeathCount desc

--
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Show continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	( sum(cast(new_deaths as int))/ sum(new_cases) ) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%state%'
where continent is not null
-- group by date
order by 1, 2

-- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
	(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
		as RollingPeopleVaccinated
	--	, (RollingPeopleVaccinated/ population) * 100
	from PortfolioProject..CovidDeaths dea 
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	-- order by 2, 3
	)
select *, (RollingPeopleVaccinated/ Population) * 100
from PopvsVac

-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2, 3

select *, (RollingPeopleVaccinated/ Population) * 100
from #PercentPopulationVaccinated

-- Creating View to store data for late visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

select * 
from PercentPopulationVaccinated