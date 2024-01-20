

select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--From PortfolioProject..covidvaccination
--order by 3,4

-- select Data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--This shows the likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
From PortfolioProject..CovidDeaths
WHERE	location LIKE 'Nigeria%'
and  continent is not null
order by 1,2

--Looking at population vs Total cases
--This shows the of the population tha got covid in a country
select location, date, population, total_cases, (total_cases/population)*100 AS  COVIDnfectedpercentage
From PortfolioProject..CovidDeaths
--WHERE	location LIKE 'Nigeria%'
where continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

select location, population,MAX(total_cases)as Highestinfectioncount, MAX((total_cases/population))*100 as COVIDinfectedpercentage
From PortfolioProject..CovidDeaths
--WHERE	location LIKE 'Nigeria%'
where continent is not null
Group By location,population
order by COVIDinfectedpercentage desc


   

 --Showing countries with highest death count per population   

 select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE	location LIKE 'Nigeria%'
where continent is not null
Group By location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN TO CONTINENT

--showing the continent  with the highest death count
 select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE	location LIKE 'Nigeria%'
where continent is not null
Group By continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 AS  Deathpercentage
From PortfolioProject..CovidDeaths
--WHERE	location LIKE 'Nigeria%'
where continent is not null
Group by date
order by 1,2

--For general all cases and deaths in the world
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 AS  Deathpercentage
From PortfolioProject..CovidDeaths
--WHERE	location LIKE 'Nigeria%'
where continent is not null
order by 1,2

--Join the death and vaccination table together
Select *
From portfolioproject..CovidVaccinations

Select *
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, Dea.date, dea.population, Vac.new_vaccinations
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = vac.date
where Dea.continent is not null
order by  2,3


--ROLLING COUNT
Select dea.continent, dea.location, Dea.date, dea.population, Vac.new_vaccinations, 
SUM(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = vac.date
where Dea.continent is not null
order by  2,3


--USE CTE
With PopvsVac (continent, location, Date, Population, new_vaccinations,  RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, Dea.date, dea.population, Vac.new_vaccinations, 
SUM(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = vac.date
where Dea.continent is not null
--order by  2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--OR

--TEMP TABLE
DROP Table if exists  #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationvaccinated
Select dea.continent, dea.location, Dea.date, dea.population, Vac.new_vaccinations, 
SUM(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = vac.date
where Dea.continent is not null
order by  2,3


select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationvaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, Dea.date, dea.population, Vac.new_vaccinations, 
SUM(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = vac.date
where Dea.continent is not null
--order by  2,3


Select *
From  PercentPopulationVaccinated








