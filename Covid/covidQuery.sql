/*
Covid 19 Data Exploration 

Skills used: Aggregate Functions, Converting Data Types, Creating Views, CTEs, Joins, Temp Tables, Windows Functions

*/

--------------------------------------------------------------------------------------------------------------------------

-- Basic Queries and Accessing Tables

-- Selects all data to check imported correctly

Select *
From covidProject..covidDeaths
Where continent is not null 
Order by 3, 4


-- Presents starting data

Select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From covidProject..covidDeaths
Where continent is not null 
Order by 1, 2


--------------------------------------------------------------------------------------------------------------------------

-- Presenting basic comparisons

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in UK

Select 
	location, 
	date, 
	total_cases,total_deaths, 
	(CONVERT(float, total_deaths) / NULLIF(total_cases, 0)) * 100 as deathPercentage
From covidProject..covidDeaths
Where location like '%Kingdom%'
	and continent is not null 
Order by 1, 2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select 
	location, 
	date, 
	population, 
	total_cases, 
	(CONVERT(float, total_cases) / population) * 100 as percentPopulationInfected
From covidProject..covidDeaths
-- Where location = 'United Kingdom' -- Can add this to see in a specific country
Order by 1,2


-- Highest Infection Rate vs Population
-- Shows highest infection count compared to population

Select 
	location, 
	population, 
	MAX(total_cases) as HighestInfectionCount,  
	MAX((CONVERT(float, total_cases) / population)) * 100 as percentPopulationInfected
From covidProject..covidDeaths
Group by location, population
Order by percentPopulationInfected desc


-- Lowest Infection Rate vs Population
-- Shows lowest infection count compared to population

Select 
	location, 
	population, 
	MAX(total_cases) as HighestInfectionCount,  
	MAX((CONVERT(float, total_cases) / population)) * 100 as percentPopulationInfected
From covidProject..covidDeaths
Where total_cases is not null and continent is not null 
Group by location, population
Order by percentPopulationInfected asc


-- Death Count vs Population
-- Shows countries with highest death count by population

Select 
	location, 
	MAX(CONVERT(int, total_deaths)) as totalDeathCount
From covidProject..covidDeaths
Where continent is not null 
Group by location
Order by totalDeathCount desc


Select 
	location, 
	population,
	MAX(CONVERT(int, total_deaths)) as totalDeathCount
From covidProject..covidDeaths 
Where continent is not null 
Group by location, population
Order by totalDeathCount desc


-- Death count vs Income Bracket
-- Shows death count by income bracket

Select 
	location, 
	population,
	MAX(CONVERT(int, total_deaths)) as totalDeathCount
From covidProject..covidDeaths 
Where location like '%income'
Group by location, population
Order by totalDeathCount desc


-- Death Count vs Continent
-- Shows contintents with the highest death count per population

Select 
	continent, 
	MAX(cast(Total_deaths as int)) as totalDeathCount
From covidProject..CovidDeaths
Where continent is not null 
Group by continent
Order by totalDeathCount desc


--------------------------------------------------------------------------------------------------------------------------

-- Using SUM Function

-- Shows global cases and deaths
-- Calculates death percentage

Select 
	SUM(new_cases) as total_cases, 
	SUM(CONVERT(int, new_deaths)) as total_deaths, 
	(SUM(CONVERT(float, new_deaths)) / SUM(New_Cases)) * 100 as deathPercentage
From covidProject..covidDeaths
Where continent is not null 


-- Total Population vs Vaccinations

Select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vacs.new_vaccinations, 
	SUM(CONVERT(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as rollingCountVaccinations
From covidProject..covidDeaths deaths
Join covidProject..covidVaccinations vacs
	On deaths.location = vacs.location
	and deaths.date = vacs.date
Where deaths.continent is not null and deaths.location = 'United Kingdom' -- Can add this to see in a specific country
Order by 2,3


--------------------------------------------------------------------------------------------------------------------------

-- Using CTE to perform calculations on Partition By


-- Vaccinations vs Population
-- Shows the ratio of vaccinations and population as a percentage

With populationVsVaccination (continent, location, date, population, new_vaccinations, rollingCountVaccinations) as
(
Select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vacs.new_vaccinations, 
	SUM(CONVERT(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as rollingCountVaccinations
From covidProject..covidDeaths deaths
Join covidProject..covidVaccinations vacs
	On deaths.location = vacs.location
	and deaths.date = vacs.date
Where deaths.continent is not null -- and deaths.location = 'United Kingdom' -- Can add this to see in a specific country
)
Select *, (CONVERT(float, rollingCountVaccinations) / population) * 100 as vaccinationPercentage
From populationVsVaccination
Where rollingCountVaccinations is not null
Order by 2,3


--------------------------------------------------------------------------------------------------------------------------

-- Using Temp Table to perform calculations on Partition By

-- Cases count vs Income Bracket
-- Shows cases count by income bracket and the percentage

DROP Table if exists #percentPopulationIncomeCases
Create Table #percentPopulationIncomeCases
(
location nvarchar(255),
population numeric,
totalCasesCount numeric,
)

Insert into #percentPopulationIncomeCases
Select 
	location, 
	population,
	MAX(CONVERT(int, total_cases)) as totalCasesCount
From covidProject..covidDeaths 
Where location like '%income' or location = 'World'
Group by location, population
Order by totalCasesCount desc

Select *, 
	(totalCasesCount / population) * 100 as casePercentage
From #percentPopulationIncomeCases
Order by totalCasesCount desc


--------------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations

-- Vaccinations vs Population
-- Creates a view for ratio of vaccinations and population as a percentage

Drop View if exists PercentPopulationVaccinations

Create View PercentPopulationVaccinations as
Select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vacs.new_vaccinations, 
	SUM(CONVERT(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as rollingCountVaccinations
From covidProject..covidDeaths deaths
Join covidProject..covidVaccinations vacs
	On deaths.location = vacs.location
	and deaths.date = vacs.date
Where deaths.continent is not null; -- and deaths.location = 'United Kingdom' -- Can add this to see in a specific country

Select *
From covidProject..PercentPopulationVaccinations