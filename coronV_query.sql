
--- *** Exploration ***
Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null -- when it is null, it means location is recorded for a continent and not a country
Order By 3,4


--Select *
--From PortfolioProject.dbo.CovidVaccine
--Where continent is not null
--Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


--- *** Total Cases Stats *** 
-- Total cases vs Total Deaths
-- shows likelihood of dying in the US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From PortfolioProject..CovidDeaths
Where location like '%states%' AND  continent is not null
Order By 1,2

-- Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Order By 1,2

-- Looking at countries with highest infection rate by population
Select location, population, Max(total_cases) AS highest_number_infected , Max((total_cases/population)*100) AS infection_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By 4 DESC


-- **** Total Death ***  
-- showing countries with the highest deaths 
Select location, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order By 2 DESC

-- Break things by Continent
Select location AS Continent, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null AND  location not in ('World', 'European Union', 'International')
Group By location
Order By 2 DESC

-- showing the highest death count per cases 
-- Global
Select SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths , 
	   SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order By 1,2


-- Looking at Total Population vs Vaccination 
-- **** Covid Vaccination ***  
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--USE Common Table Expresion (CTE) used to define temp table/result
With PopvsVac (Continent, Location, Date, Population, NevVaccination, RollingPeopleVaccinated)
As
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null)
--Order By 2,3 --- order is invalid in CTEs)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
Order By Location


-- Temp Table

Drop Table If Exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
Order By Location


--- Create View

Create View TotalDeathByContinent As 
Select location AS Continent, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null AND  location not in ('World', 'European Union', 'International')
Group By location
--Order By 2 DESC not allowed in a view

Drop View If exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated As --# is not allowed in a name View
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3 not allowed in a view

Select *
From PercentPopulationVaccinated








