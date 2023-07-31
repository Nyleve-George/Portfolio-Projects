--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

----Select data from both tables and order first by location (3) and then by continent (4)

--Select*
--From CovidDeathsFile
--order by 3,4
--ALTER TABLE [dbo].[CovidDeathsFile] ALTER COLUMN [Total_deaths] Float;

--select*
--From CovidVaccFile
--order by 3,4

--Select data to be used 

Select location, date, total_cases, New_cases, total_deaths, population
From PortfolioProject..CovidDeathsFile
Where continent is not Null
order by 1,2

--Total cases vs Total deaths in percentile
--Which shows the likelihood of dying if you contract covid and live in the US

 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeathsFile
where location like '%States%'
order by 1,2

--Total cases Vs Population
--shows Percentage of US Population with Covid
Select location, date, population, total_cases, (total_cases/population)*100 As CovidpercentageOfPopulation
From PortfolioProject..CovidDeathsFile
where location like '%States%'
order by 1,2 

--Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 
As CovidpercentageOfPopulation
From PortfolioProject..CovidDeathsFile
Where continent is not Null
Group by location, Population
order by CovidpercentageOfPopulation desc

--Showing Countries with highest Death Count per Population

Select location,  Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeathsFile
Where continent is not Null
Group by location
order by TotalDeathCount desc

--By continent
---Showing Continent with ighest death count

Select location,  Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeathsFile
Where continent is Null
Group by location
order by TotalDeathCount desc

Select date, SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(Cast(new_deaths as float))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeathsFile
where continent is not null 
Group By date
order by 1,2

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(Cast(new_deaths as float))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeathsFile
where continent is not null 
order by 1,2


--Total population vs Vaccinations

select DF.continent, DF.location, DF.date, DF.population, VF.new_vaccinations
, SUM(VF.new_vaccinations) over (Partition by DF.Location order by DF.location, DF.date )
as RollingVaccinatedPopulation
From CovidDeathsFile as DF
Join CovidVaccFile as VF
   on DF.location = VF.location
   and DF.date = VF.date
   Where DF.continent is not null
   order by 2,3

--Use CTE
With PopvsVac (continent, Location, date, population, new_vaccinations, RollingVaccinatedPopulation)
as
(
select DF.continent, DF.location, DF.date, DF.population, VF.new_vaccinations
, SUM(VF.new_vaccinations) over (Partition by DF.Location order by DF.location, DF.date )
as RollingVaccinatedPopulation
From CovidDeathsFile as DF
Join CovidVaccFile as VF
   on DF.location = VF.location
   and DF.date = VF.date
Where DF.continent is not null
)
Select*, (RollingVaccinatedPopulation/Population)*100
From PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_Vaccinations numeric,
RollingVaccinatedPopulation numeric)

insert into #PercentPopulationVaccinated
select DF.continent, DF.location, DF.date, DF.population, VF.new_vaccinations
, SUM(VF.new_vaccinations) over (Partition by DF.Location order by DF.location, DF.date )
as RollingVaccinatedPopulation
From CovidDeathsFile as DF
Join CovidVaccFile as VF
   on DF.location = VF.location
   and DF.date = VF.date
--Where DF.continent is not null
--order by 2, 3


Select*, (RollingVaccinatedPopulation/Population)*100
From #PercentPopulationVaccinated 

--Creating view to store date for visualization

Create View PercentPopulationVaccinated as
select DF.continent, DF.location, DF.date, DF.population, VF.new_vaccinations
, SUM(VF.new_vaccinations) over (Partition by DF.Location order by DF.location, DF.date )
as RollingVaccinatedPopulation
From CovidDeathsFile as DF
Join CovidVaccFile as VF
   on DF.location = VF.location
   and DF.date = VF.date
Where DF.continent is not null

