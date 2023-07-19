--select * from PortfolioProject..CovidDeaths where continent is not null

--select * from PortfolioProject..CovidVaccinations

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths order by 1,2

---total cases vs total deaths

select location,date,total_cases, total_deaths,(CAST(total_deaths AS decimal) / CAST(total_cases AS decimal))*100 as death_percentage
from CovidDeaths order by 1,2

--- estimated death percentage in Australia due to covid

select location,date,total_cases, total_deaths,(CAST(total_deaths AS decimal) / CAST(total_cases AS decimal))*100 as death_percentage
from 
CovidDeaths
where location like '%Australia%' order by 1,2

-- average death percentage of Australia 
select location,avg((CAST(total_deaths AS decimal) / CAST(total_cases AS decimal))*100) as avg_death_percentage
from 
CovidDeaths group by location having location='Australia'

-- countries with highest infection rate compared to population
select location, population, max(cast(total_cases as int)) as highest_infection, max(CAST(total_cases AS decimal) / CAST(population AS decimal))*100 as percentPopulationInfected 
from CovidDeaths group by location,population
order by percentPopulationInfected desc

-- countries with highest infection rate compared to population
select location, max(cast(total_deaths as int)) as MaxDeathCount
from CovidDeaths 
where continent is not null 
group by location
order by MaxDeathCount desc

-- Global covid data based on location

select location,sum(new_cases) as new_CasesCount, sum(new_deaths) as new_deathsCount, sum(new_deaths)/sum(new_cases)*100
as new_deaths_percentage
from CovidDeaths where continent is not null
group by location
order by 1,2

-- Exploring data of total population vs vaccinations 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
from CovidDeaths cd join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

-- count of new vaccinations by partitioning the location and order by location & date
-- using CTE 
--total vaccinated based on location vs population
with PopvsVacc(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as BIGINT)) over (partition by cd.location order by cd.location,cd.date) 
as RollingPeopleVaccinated
from CovidDeaths cd join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 from PopvsVacc

-- Creating views for visualizations in future 
create view HighestInfectionRateCountries as
select location, max(cast(total_deaths as int)) as MaxDeathCount
from CovidDeaths 
where continent is not null 
group by location

--View for Percentage of population vaccinated
create view PercentPopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as BIGINT)) over (partition by cd.location order by cd.location,cd.date) 
as RollingPeopleVaccinated
from CovidDeaths cd join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null