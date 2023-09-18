/*
Wealth Inequality Data Exploration 

Skills used: Aggregate Functions, Converting Data Types, Creating Views, CTEs, Joins, Temp Tables, Windows Functions

*/

--------------------------------------------------------------------------------------------------------------------------

-- Basic Queries and Accessing Tables

-- Selects all data to check imported correctly

Select *
From wealthInequality..WealthInequality


-- Presents starting data

Select Country, Year, Gini_coefficient_before_tax_World_Inequality_Database
From wealthInequality..WealthInequality
Where Gini_coefficient_before_tax_World_Inequality_Database is not null 
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

-- Presenting basic comparisons

-- Income share of richest 0.1% vs poorest 50% in the UK
-- Shows income disparity between richest and poorest 

Select Country, 
	Year, 
	Income_share_of_the_richest_0_1_before_tax_World_Inequality_Database, 
	Income_share_of_the_poorest_50_before_tax_World_Inequality_Database, 
	(Income_share_of_the_richest_0_1_before_tax_World_Inequality_Database/Income_share_of_the_poorest_50_before_tax_World_Inequality_Database)*100 as wealthInequalityPercentage
From wealthInequality..WealthInequality
Where Country like '%kingdom%' and 
	Income_share_of_the_richest_0_1_before_tax_World_Inequality_Database is not null and 
	Income_share_of_the_poorest_50_before_tax_World_Inequality_Database is not null
order by 1,2


-- Income share of richest 1% vs poorest 50% in the UK
-- Shows income disparity between richest and poorest 

Select Country, 
	Year, 
	Income_share_of_the_richest_1_before_tax_World_Inequality_Database, 
	Income_share_of_the_poorest_50_before_tax_World_Inequality_Database, 
	(Income_share_of_the_richest_1_before_tax_World_Inequality_Database/Income_share_of_the_poorest_50_before_tax_World_Inequality_Database)*100 as wealthInequalityPercentage
From wealthInequality..WealthInequality
Where Country like '%kingdom%' and 
	Income_share_of_the_richest_1_before_tax_World_Inequality_Database is not null and 
	Income_share_of_the_poorest_50_before_tax_World_Inequality_Database is not null
order by 1,2


-- Income share of richest 10% vs poorest 50% in the UK
-- Shows income disparity between richest and poorest 

Select Country, 
	Year, 
	Income_share_of_the_richest_10_before_tax_World_Inequality_Database, 
	Income_share_of_the_poorest_50_before_tax_World_Inequality_Database, 
	(Income_share_of_the_richest_10_before_tax_World_Inequality_Database/Income_share_of_the_poorest_50_before_tax_World_Inequality_Database)*100 as wealthInequalityPercentage
From wealthInequality..WealthInequality
Where Country like '%kingdom%' and 
	Income_share_of_the_richest_10_before_tax_World_Inequality_Database is not null and 
	Income_share_of_the_poorest_50_before_tax_World_Inequality_Database is not null
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

-- Using MAX function

-- Countries with Highest Gini Coefficient

Select 
	Country, 
	MAX(Gini_coefficient_before_tax_World_Inequality_Database) as MaxGini
From wealthInequality..WealthInequality
Group by Country
Order by MaxGini desc


-- Countries with Biggest Income Share from 0.1%

Select 
	Country, 
	MAX(Income_share_of_the_richest_0_1_before_tax_World_Inequality_Database) as Max0_1IncomeShare
From wealthInequality..WealthInequality
Group by Country
Order by Max0_1IncomeShare desc


-- Countries with Biggest Income Share from 1%

Select 
	Country, 
	MAX(Income_share_of_the_richest_1_before_tax_World_Inequality_Database) as Max1IncomeShare
From wealthInequality..WealthInequality
Group by Country
Order by Max1IncomeShare desc


--------------------------------------------------------------------------------------------------------------------------

-- Using AVG function

-- Showing which year had the largest average Gini Coefficient

Select 
	Year, 
	AVG(cast(Gini_coefficient_before_tax_World_Inequality_Database as float)) as AvgGini
From wealthInequality..WealthInequality
Where Gini_coefficient_before_tax_World_Inequality_Database is not null
Group by Year
Order by AvgGini desc



-- Showing which country has the largest average Gini Coefficient

Select 
	Country, 
	AVG(Gini_coefficient_before_tax_World_Inequality_Database) as AvgGini
From wealthInequality..WealthInequality
Where Gini_coefficient_before_tax_World_Inequality_Database is not null
Group by Country
Order by AvgGini desc, Country asc


-- Showing which region has the largest average Gini Coefficient

Select 
	Country as Region,
	AVG(Gini_coefficient_before_tax_World_Inequality_Database) as AvgGini
From wealthInequality..WealthInequality
Where Gini_coefficient_before_tax_World_Inequality_Database is not null and Country like '%(WID)'
Group by Country
Order by AvgGini desc, Region asc


-- Showing which country has the largest difference Gini Coefficient (Max vs Min)

Select 
	Country, 
	MAX(Gini_coefficient_before_tax_World_Inequality_Database) - MIN(Gini_coefficient_before_tax_World_Inequality_Database) as DiffGini
From wealthInequality..WealthInequality
Where Gini_coefficient_before_tax_World_Inequality_Database is not null
Group by Country
Order by DiffGini desc, Country asc


-- Showing which region has the largest difference Gini Coefficient (Max vs Min)

Select 
	Country as Region, 
	MAX(Gini_coefficient_before_tax_World_Inequality_Database) - MIN(Gini_coefficient_before_tax_World_Inequality_Database) as DiffGini
From wealthInequality..WealthInequality
Where Gini_coefficient_before_tax_World_Inequality_Database is not null and Country like '%(WID)'
Group by Country
Order by DiffGini desc, Region asc


--------------------------------------------------------------------------------------------------------------------------

-- Using Join 

-- Country Vs World Gini Coefficient 
-- Shows which country have a higher than world average Gini coefficient for each year

Select 
	a.Country, 
	a.Year,
	a.Gini_coefficient_before_tax_World_Inequality_Database as CountryGiniCoefficient,
	b.Gini_coefficient_before_tax_World_Inequality_Database as WorldGiniCoefficient
From wealthInequality..WealthInequality a
Join wealthInequality..WealthInequality b
	On a.Year = b.Year
	AND b.Country = 'World'
Where 
	a.Gini_coefficient_before_tax_World_Inequality_Database  is not null 
	AND b.Gini_coefficient_before_tax_World_Inequality_Database  is not null 
	-- AND a.Country = 'United Kingdom' -- Can add this to see in a specific country
Order by a.Country, a.Year


--------------------------------------------------------------------------------------------------------------------------

-- Using CTE to perform calculations on Partition By

-- Year Vs Average Gini Coefficient by Country
-- Shows which years have a higher than average Gini coefficient for each country

With giniCoefficientYearComparison (Country, Year, Gini, AvgGini) as
(
Select 
	Country, 
	Year,
	Gini_coefficient_before_tax_World_Inequality_Database,
	AVG(Gini_coefficient_before_tax_World_Inequality_Database) OVER (Partition by Country) as AvgGini
From wealthInequality..WealthInequality
Where Gini_coefficient_before_tax_World_Inequality_Database is not null
)
Select 
	Country,
	Year,
	CASE
		When Gini > AvgGini Then 'Yes'
		Else 'No'
	END as ifAboveAverageGiniCoefficient
From giniCoefficientYearComparison
Order by Country, Year


--------------------------------------------------------------------------------------------------------------------------

-- Using Temp Table to perform calculations on Partition By

-- Country Vs World Gini Coefficient 
-- Shows which countries have a higher than world average Gini coefficient for each year

DROP Table if exists #worldCountryGiniComparison
Create Table #worldCountryGiniComparison
(
Country nvarchar(255),
Year numeric,
CountryGiniCoefficient float,
WorldGiniCoefficient float
)

Insert into #worldCountryGiniComparison
Select 
	a.Country, 
	a.Year,
	a.Gini_coefficient_before_tax_World_Inequality_Database as CountryGiniCoefficient,
	b.Gini_coefficient_before_tax_World_Inequality_Database as WorldGiniCoefficient
From wealthInequality..WealthInequality a
Join wealthInequality..WealthInequality b
	On a.Year = b.Year
	AND b.Country = 'World'
Where 
	a.Gini_coefficient_before_tax_World_Inequality_Database  is not null 
	AND b.Gini_coefficient_before_tax_World_Inequality_Database  is not null 

Select *,
	CASE
		When CountryGiniCoefficient > WorldGiniCoefficient Then 'Yes'
		Else 'No'
	END as ifAboveWorldGiniCoefficient
From #worldCountryGiniComparison
-- Where Country = 'United Kingdom' -- Can add this to see in a specific country
Order by Country, Year

--------------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations

-- Country Vs World Gini Coefficient 
-- Creates a view for which countries have a higher than world average Gini coefficient for each year

Drop View if exists worldCountryGiniComparison

Create View worldCountryGiniComparison as
Select 
	a.Country, 
	a.Year,
	a.Gini_coefficient_before_tax_World_Inequality_Database as CountryGiniCoefficient,
	b.Gini_coefficient_before_tax_World_Inequality_Database as WorldGiniCoefficient
From wealthInequality..WealthInequality a
Join wealthInequality..WealthInequality b
	On a.Year = b.Year
	AND b.Country = 'World'
Where 
	a.Gini_coefficient_before_tax_World_Inequality_Database  is not null 
	AND b.Gini_coefficient_before_tax_World_Inequality_Database  is not null 
	AND a.Country = 'United Kingdom' -- Can add this to see in a specific country

Select *
From wealthInequality..worldCountryGiniComparison