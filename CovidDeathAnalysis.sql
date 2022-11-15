select * 
from PortfolioProject..CovidDeaths
order by 3,4;

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4;

-- working first on covid deaths

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- data overview
select continent,location,date,total_cases,new_cases,total_deaths,population,
reproduction_rate,icu_patients,hosp_patients,weekly_hosp_admissions,weekly_icu_admissions
from PortfolioProject..CovidDeaths
order by population desc;


-- TOTAL CASES VS TOTAL DEATHS
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
order by 5 desc;

-- Likelihood of dying for any particular country
select location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'india'
and continent is not null
order by 4 desc;

-- Total cases Vs Population

select location,date,population,total_cases,(total_cases/population)*100 AS InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'world'
order by 4 desc;

-- Maximum damage or max infected population percentage of countries

select location,population,max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 AS Max_Infected_Population_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'India'
group by location,population
order by Max_Infected_Population_Percentage desc;

--select distinct(location)
--from PortfolioProject..CovidDeaths;


-- SHOWING COUNTRIES WITH HIGHER DEATH COUNT
select location,population,max(cast(total_deaths as INT))as totalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by totalDeathCount desc;
 
 -- SHOWING COUNTRIES WITH HIGHER DEATH COUNT PER POPULATION
select location,population,max(cast(total_deaths as INT))as totalDeathCount,
((max(total_deaths))/population)*100 AS DeathCountPerPopulation
from PortfolioProject..CovidDeaths
--where location like 'India'
where continent is not null
group by location,population
order by DeathCountPerPopulation desc;
 
 -- Continents with higher death count
 select continent,sum(cast(total_deaths as INT))as totalDeathCount,sum(population) as Population
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totalDeathCount desc;

-- Aliter

select location,max(cast(total_deaths as INT))as totalDeathCount,max(population) as Population
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by totalDeathCount desc;

 -- Countries with higher death count
 select location,max(cast(total_deaths as INT))as totalDeathCount,max(population) as Population
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by totalDeathCount desc;

-- GLOBAL DATA
-- Total death worldwide
 Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as Total_Deaths,
 ((sum(cast(new_deaths as int)))/sum(new_cases))*100 as Death_Percentage
 from PortfolioProject..CovidDeaths
 where continent is null 
 order by 1,2;

 -- Daily global status of covid
 Select date,sum(new_cases) as new_cases_today,sum(cast(new_deaths as int)) as Total_deaths_today,
 (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage_today
 from PortfolioProject..CovidDeaths
 where continent is null and new_cases !='0'
 group by date
 order by 1;

 -- Total Global death % 
 Select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_deaths,
 (sum(cast(new_deaths as int))/sum(new_cases))*100 as Total_Death_Percentage
 from PortfolioProject..CovidDeaths
 where continent is null and new_cases !='0'
 order by 1,2;
  

-- WORKING ON COVID VACCINATIONS TABLE
Select * 
from PortfolioProject..CovidVaccinations;

-- Looking at Total population vs vaccination

Select death.date,death.continent,death.location,death.population,vacc.new_vaccinations,
--SUM(CAST(vacc.new_vaccinations as bigint)) over (Partition by death.location)(same thing as convert)
SUM(CONVERT(bigint,vacc.new_vaccinations)) over (Partition by death.location order by death.location, death.date) as rollingPeopleVAccinated
from PortfolioProject..CovidDeaths Death
join PortfolioProject..CovidVaccinations Vacc
on Death.location=Vacc.location
and Death.date=Vacc.date
where death.continent is not null
order by 3,1;

-- USE CTE
With PopVsVacc(date,continent,location,population,new_vaccinations,rollingPeopleVaccinated) 
as
(
Select death.date,death.continent,death.location,death.population,vacc.new_vaccinations,
--SUM(CAST(vacc.new_vaccinations as bigint)) over (Partition by death.location)(same thing as convert)
SUM(CONVERT(bigint,vacc.new_vaccinations)) over (Partition by death.location order by death.location, death.date) as rollingPeopleVAccinated
from PortfolioProject..CovidDeaths Death
join PortfolioProject..CovidVaccinations Vacc
on Death.location=Vacc.location
and Death.date=Vacc.date
where death.continent is not null
-- order by 3,1;
)
Select *,(rollingPeopleVaccinated/population)*100 as percentageofpplvacc
from PopVsVacc ;

-- TEMP TABLE
DROP table if EXISTS #PercentPeopleVaccinated 
-- (to make changes to the table first drop it then u can make changes
Create Table #PercentPeopleVaccinated
(
date Datetime,
continent nvarchar(255),
location nvarchar(255),
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
Insert into #PercentPeopleVaccinated
Select death.date,death.continent,death.location,death.population,vacc.new_vaccinations,
--SUM(CAST(vacc.new_vaccinations as bigint)) over (Partition by death.location)(same thing as convert)
SUM(CONVERT(bigint,vacc.new_vaccinations)) over (Partition by death.location order by death.location, death.date) as rollingPeopleVAccinated
from PortfolioProject..CovidDeaths Death
join PortfolioProject..CovidVaccinations Vacc
on Death.location=Vacc.location
and Death.date=Vacc.date
--where death.continent is not null
-- order by 3,1;

Select *,(rollingPeopleVaccinated/population)*100 as percentageofpplvacc
from #PercentPeopleVaccinated ;

-- CREATING VIEWS FOR VISUALISATIONS

Create View PercentPeopleVaccinated as 
Select death.date,death.continent,death.location,death.population,vacc.new_vaccinations,
--SUM(CAST(vacc.new_vaccinations as bigint)) over (Partition by death.location)(same thing as convert)
SUM(CONVERT(bigint,vacc.new_vaccinations)) over (Partition by death.location order by death.location, death.date) as rollingPeopleVAccinated
from PortfolioProject..CovidDeaths Death
join PortfolioProject..CovidVaccinations Vacc
on Death.location=Vacc.location
and Death.date=Vacc.date
--where death.continent is not null
-- order by 3,1;

Select * 
from PercentPeopleVaccinated;