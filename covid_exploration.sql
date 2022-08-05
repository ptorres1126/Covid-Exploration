/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
From `portfolio-projects-358318.covid.covid_deaths`
Where continent is not null
order by 3,4

-- Select data that we are going to be using. 
Select location, date, total_cases, new_cases, total_deaths, population
From `portfolio-projects-358318.covid.covid_deaths`
Where continent is not null
Order by 1,2

-- Total Cases vs. Total Deaths
-- Show likelihood of death if infected with Covid in your country. 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From `portfolio-projects-358318.covid.covid_deaths`
--Where location like 'United States'
Order by 1,2

-- Total Cases vs. Population
-- Shows what percentage of population in infected with Covid. 
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From `portfolio-projects-358318.covid.covid_deaths`
--Where location like 'United States'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
From `portfolio-projects-358318.covid.covid_deaths`
--Where location like 'United States'
Group by location, population
Order by PercentPopulationInfected desc

-- Countries with Highest Infection Rate compared to Population by date
Select location, date, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
From `portfolio-projects-358318.covid.covid_deaths`
--Where location like 'United States'
Group by location, population, date
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as TotalDeathCount
From `portfolio-projects-358318.covid.covid_deaths`
--Where location like 'United States'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(Total_deaths) as TotalDeathCount
From `portfolio-projects-358318.covid.covid_deaths`
--Where location like 'United States'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global Total New Cases by Date
Select date, SUM(new_cases) as total_cases,
From `portfolio-projects-358318.covid.covid_deaths`
where continent is not null 
Group By date
Order by 1

-- Global Death Percentage by Date
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_Cases)*100 as DeathPercentage
From `portfolio-projects-358318.covid.covid_deaths`
where continent is not null 
Group By date
order by 1,2

-- Global Death Percentage 
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_Cases)*100 as DeathPercentage
From `portfolio-projects-358318.covid.covid_deaths`
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
From `portfolio-projects-358318.covid.covid_deaths` dea
Join `portfolio-projects-358318.covid.covid_vaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Total Population vs Vaccinations
-- Shows Rolling Count of Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated, 
From `portfolio-projects-358318.covid.covid_deaths` dea
Join `portfolio-projects-358318.covid.covid_vaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
From `portfolio-projects-358318.covid.covid_deaths` dea
Join `portfolio-projects-358318.covid.covid_vaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac
