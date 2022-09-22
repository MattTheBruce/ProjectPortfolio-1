--select * 
--from portfolioproject..['covid deaths']
--order by 3,4


--select * 
--from portfolioproject..['covid vaccinations']
--order by 3,4

--select data that we are going to use

--select Location, date, total_cases, new_cases, total_deaths, population
--from portfolioproject..['covid deaths']
--order by 1,2

--looking at total cases vs total deaths, give % chance of death from covid-19

--select Location, date, Population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathsPercentage
--from portfolioproject..['covid deaths']
--where location = 'United Kingdom'
--order by 1,2

--looking at countries w highest infection rate compared to population size

select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS HighestPercentageInfected
from portfolioproject..['covid deaths']
group by Location, Population
order by HighestPercentageInfected DESC


-- showing countries w highest death count as % of population

select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolioproject..['covid deaths']
where continent is null
--or location != 'World' or 'High income' or 'Upper middle income' or 'Lower middle income' or 'Lower income'
group by Location
order by TotalDeathCount DESC

-- showing continents with highest death count


select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolioproject..['covid deaths']
where continent is not null
group by continent
order by TotalDeathCount DESC


-- global numbers

select SUM(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathsPercentage
from portfolioproject..['covid deaths']
where continent is not null
--Group By date
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from portfolioproject..['covid deaths'] dea
join portfolioproject..['covid vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USING CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from portfolioproject..['covid deaths'] dea
join portfolioproject..['covid vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100 AS PercentagePopVaccinated
From PopVsVac


-- TEMP TABLE

--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from portfolioproject..['covid deaths'] dea
join portfolioproject..['covid vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100 AS PercentagePopVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from portfolioproject..['covid deaths'] dea
join portfolioproject..['covid vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * 
from PercentPopulationVaccinated