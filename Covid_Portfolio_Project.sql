--select * from PortfolioProject..covid_vaccinations
--order by 3,4

select * from PortfolioProject..covid_Deathes
where continent is not null
order by 3,4

--Select data that we are going to be using
select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_Deathes
where continent is not null
order by 1, 2

--looking at total_cases vs total deathes
-- shows the pourcentage of deaths in your cintry if you had covid

select location,date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as total_deathesPercentage
from PortfolioProject..covid_Deathes
--where location like 'MOR%'
order by 1, 2


--looking at total_cases vs population
-- show what percentage of population get covid


select location,date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as total_infectionPercentage
from PortfolioProject..covid_Deathes
--where location like 'MOR%'
order by 1, 2


-- looking for contries with the highest infection rate campared with population


select location, MAX(total_cases) as highestInfectionCount, population, max((cast(total_cases as float)/cast(population as float)))*100 as total_infectionPercentage
from PortfolioProject..covid_Deathes
--where location like 'MOR%'
where continent is not null
group by location, population
order by total_infectionPercentage desc


-- showing contries with highest death count per population

select location, MAX(cast(total_deaths as int)) as highestDeathsCount
from PortfolioProject..covid_Deathes
--where location like 'MOR%'
where continent is not null
group by location
order by highestDeathsCount desc

-- lets do the same thing but this time with continent

select continent, MAX(cast(total_deaths as int)) as highestDeathsCount
from PortfolioProject..covid_Deathes
--where location like 'MOR%'
where continent is not null
group by continent
order by highestDeathsCount desc


--	global numbers

select date, sum(cast(new_cases as float)) as total_cases , sum(cast(new_deaths as float))as total_deaths,case when sum(cast(new_cases as float))!=0 then sum(cast(new_deaths as float))/ sum(cast(new_cases as float))*100 else null end as deathesPercentage
from PortfolioProject..covid_Deathes
--where location like 'MOR%'
where continent is not null
group by date
order by 1, 2

-- looking at total population vs Vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over  (partition by dea.location ) as RollingPeopleVaccinated
from PortfolioProject..covid_Deathes dea
 join PortfolioProject..covid_vaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- use CTE

with PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over  (partition by dea.location ) as RollingPeopleVaccinated
from PortfolioProject..covid_Deathes dea
 join PortfolioProject..covid_vaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated / population)* 100 as percentagePeopleVac
from PopvsVac