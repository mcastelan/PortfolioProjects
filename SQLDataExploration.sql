select * from dbo.CovidDeaths
where continent is not null
order by 3,4

--select * from dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location,Date, total_cases, new_cases,total_deaths, population
 from dbo.CovidDeaths
 where continent is not null
 order by 3,4

 -- Looking at total cases vs Total Deaths
 -- Shows likelihood of dying if you contract covid in your country

 Select Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPct
 from dbo.CovidDeaths
 --where location like '%Mexico%'
 where continent is not null
 order by 1,2


 -- Looking at total cases vs Population
 -- Shows what percentage of population got covid

 Select Location, Date, total_cases, population, (total_cases/population)*100 as ContagionPercentage
 from dbo.CovidDeaths
 where continent is not null
 --where location like '%Mexico%'
 order by 1,2


 -- Looking at countries with highest infection rate compared to population

 Select Location,  population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
 from dbo.CovidDeaths
 where continent is not null
 --where location like '%Mexico%'
 group by population,location
 order by percentpopulationinfected desc

 --Showing the countrie with the highest Death count per population
   Select Location,   max(cast(total_deaths as int)) as TotalDeathCount
 from dbo.CovidDeaths
 where continent is not null
 --where location like '%Mexico%'
 group by Location
 order by TotalDeathCount desc



 --LET'S BREAK THINGS DOWN BY CONTINENT


 --Showing the continents with the highest count per population
    Select continent,   max(cast(total_deaths as int)) as TotalDeathCount
 from dbo.CovidDeaths
 where continent is not  null
 --where location like '%Mexico%'
 group by continent
 order by TotalDeathCount desc


 --Global Numbers

  Select   sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDEaths,
  (sum(cast (new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
 from dbo.CovidDeaths
  where continent is not null
  order by 1,2

  --Looking at total population vs Vaccination

  select d.continent,d.location,d.date,d.population,v.new_vaccinations
  ,SUM(cast(v.new_vaccinations as int)) over(partition by d.location order  by d.location,d.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
    from dbo.CovidDeaths D
  join dbo.CovidVaccinations V
  on D.date = V.date and d.location = v.location
  where d.continent is not null
  order by 2,3

  --use CTE
  With PopVsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
  as 
  (
  select d.continent,d.location,d.date,d.population,v.new_vaccinations
  ,SUM(cast(v.new_vaccinations as int)) over(partition by d.location order  by d.location,d.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
    from dbo.CovidDeaths D
  join dbo.CovidVaccinations V
  on D.date = V.date and d.location = v.location
  where d.continent is not null
  --order by 2,3
  )
  select *,(RollingPeopleVaccinated/Population)*100 
  from PopVsVac

  --TEmp table
--DROP table if exists #PercentPopulationVaccinated
  declare   @PercentPopulationVaccinated table
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date DateTime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
  Insert into @PercentPopulationVaccinated
    select d.continent,d.location,d.date,d.population,v.new_vaccinations
  ,SUM(cast(v.new_vaccinations as int)) over(partition by d.location order  by d.location,d.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
    from dbo.CovidDeaths D
  join dbo.CovidVaccinations V
  on D.date = V.date and d.location = v.location
  where d.continent is not null

    select *,(RollingPeopleVaccinated/Population)*100 
  from @PercentPopulationVaccinated

  --Creating view to store data for later visualization

  Create view PercentPopulationVaccinated as 
   select d.continent,d.location,d.date,d.population,v.new_vaccinations
  ,SUM(cast(v.new_vaccinations as int)) over(partition by d.location order  by d.location,d.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
    from dbo.CovidDeaths D
  join dbo.CovidVaccinations V
  on D.date = V.date and d.location = v.location
  where d.continent is not null

  select * from PercentPopulationVaccinated