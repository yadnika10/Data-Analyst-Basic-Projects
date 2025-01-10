
select * from [Project(Analyst)].dbo.coviddeaths order by 3,4;
select * from [Project(Analyst)].dbo.covidvaccinations order by 3,4;

select Location,date, total_cases, new_cases, total_deaths,population from [Project(Analyst)].dbo.coviddeaths
order by 1,2

-- Looking at Total Cases vs Total deaths

select location,date,total_cases,total_deaths,Round((total_deaths/Total_cases)*100,1) as death_per from dbo.coviddeaths 
where location like '%India%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what % of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as Total_cases_per_population
from dbo.coviddeaths 
where location like '%India%'
order by 1,2

-- Countries with Highest Infection Rate compared to population

select location,population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100)
as PercentPopulationInfected
from dbo.coviddeaths 
--where location like '%India%'
group by location,population
order by 4 desc

-- Countries with Highest Death Count per Population

select location,population,MAX(cast(Total_deaths as int)) as MaxDeathCount-- Max((total_cases/population)*100)
--as PercentPopulationInfected
from dbo.coviddeaths 
where continent is not null --and location = 'India'
group by location,population
order by 3 desc

-- Lets Breakdown by Continent

select Location,MAX(cast(Total_deaths as int)) as MaxDeathCount-- Max((total_cases/population)*100)
--as PercentPopulationInfected
from dbo.coviddeaths 
where continent is null
group by location
order by 2 desc

--Global Numbers

select sum(new_cases) as Total_new_Cases,sum(cast(new_deaths as int)) as Total_New_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from dbo.coviddeaths 
where continent is not null
--group by date
order by 1,2 desc

-----Covid Vaccinations-------

select * from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Looking at total populations vs vaccinations

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeepVaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac (Continent,location,Date,Population,new_vaccinations,RollingPeepVaccinated) as
(select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeepVaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
select *,(RollingPeepVaccinated/Population)*100 from PopvsVac

--TEMP Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeepVaccinated numeric)

Insert Into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeepVaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(RollingPeepVaccinated/Population)*100 from #PercentPopulationVaccinated

--Create View

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeepVaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(RollingPeepVaccinated/Population)*100 from PercentPopulationVaccinated