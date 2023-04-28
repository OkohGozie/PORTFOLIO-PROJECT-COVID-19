SELECT *
FROM PORTFOLIOPROJECT..Covid19Deaths
WHERE continent is NULL
ORDER BY 3,4

--SELECT *
--FROM PORTFOLIOPROJECT..Covid19Vaccinations
--ORDER BY 3,4

--The data I will be working on
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PORTFOLIOPROJECT..Covid19Deaths
WHERE continent is NULL
ORDER BY 1,2

--Looking at Total deaths vs Total cases
SELECT *
FROM PORTFOLIOPROJECT..Covid19Deaths

EXEC sp_help 'PORTFOLIOPROJECT..Covid19Deaths';

ALTER TABLE PORTFOLIOPROJECT..Covid19Deaths
ALTER COLUMN total_deaths int



select location, date, cast(total_deaths as int) as death_rate, total_cases, cast(total_deaths as int)/total_cases* 100 as DeathRate
from PORTFOLIOPROJECT..Covid19Deaths
where location like '%states%' 
order by 1,2


--Looking at Total deaths vs Population
--Shows what percentage of people got covid
select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PORTFOLIOPROJECT..Covid19Deaths
where location like '%states%' 
order by 1,2

--Countries with the highest infection rates compared to the Population.
select location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PORTFOLIOPROJECT..Covid19Deaths
Group by location, population 
--where location like '%Nigeria%'
order by PercentPopulationInfected desc

---Countries with highest Death Count Per Population
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PORTFOLIOPROJECT..Covid19Deaths
WHERE continent is NULL
Group by location 
--where location like '%Nigeria%'
Order by TotalDeathCount desc

--BY CONTINENT
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PORTFOLIOPROJECT..Covid19Deaths
WHERE continent is NULL
Group by location
--where location like '%Nigeria%'
Order by TotalDeathCount desc

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PORTFOLIOPROJECT..Covid19Deaths
WHERE continent is not NULL
Group by continent
--where location like '%Nigeria%'
Order by TotalDeathCount desc

--Global numbers
--the Continent with the highest DeathCount
select date, SUM(new_cases)AS total_cases, SUM(cast(new_deaths as int))AS total_deaths, SUM(cast(new_deaths as int))/SUM(nullif(new_cases, 0))*100 AS DeathPercentage
from PORTFOLIOPROJECT..Covid19Deaths
where continent is not NULL
Group by date
order by 1,2

select SUM(new_cases)AS total_cases, SUM(cast(new_deaths as int))AS total_deaths, SUM(cast(new_deaths as int))/SUM(nullif(new_cases, 0))*100 AS DeathPercentage
from PORTFOLIOPROJECT..Covid19Deaths
where continent is not NULL
--Group by date
order by 1,2

--Total Population VS Total Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PORTFOLIOPROJECT..Covid19Deaths dea
Join PORTFOLIOPROJECT..Covid19Vaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
where dea.continent is not NULL
order by 2,3

--With CTE

With PopVsVAC (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PORTFOLIOPROJECT..Covid19Deaths dea
Join PORTFOLIOPROJECT..Covid19Vaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
where dea.continent is not NULL
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVAC


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PORTFOLIOPROJECT..Covid19Deaths dea
Join PORTFOLIOPROJECT..Covid19Vaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
where dea.continent is not NULL
--order by 2,3
select *,(RollingPeopleVaccinated/'population')*100
from #PercentPopulationVaccinated


--Created view to store data later

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PORTFOLIOPROJECT..Covid19Deaths dea
Join PORTFOLIOPROJECT..Covid19Vaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
where dea.continent is not NULL
--order by 2,3
