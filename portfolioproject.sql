
use portfolioproject;

select * 
from Portfolioproject..[Covid deaths data]
order by 3,5; -- ordering the data by 3rd and 5th column 

-- looking at total cases vs totaldeaths percentage

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolioproject..[Covid deaths data][Covid deaths data];

-- some integer columns are set as 'nvarchar' data type , we have to chnage it to perform the calculations

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Covid deaths data';

ALTER TABLE [Covid deaths data]
ALTER COLUMN total_cases float

ALTER TABLE [Covid deaths data]
ALTER COLUMN total_deaths float

-- let's run the above query again

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS deathpercentage
FROM Portfolioproject..[Covid deaths data]
order by 1,2 ;

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS deathpercentage
FROM Portfolioproject..[Covid deaths data]
where location like "Afg%"
order by 1,2 ;


SELECT DISTINCT Location
FROM [Covid deaths data]; 

SELECT Location, date, population, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS deathpercentage
FROM [Covid deaths data]
where location = 'India';

-- Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount
from [Covid deaths data]
group by location,population
order by 3 desc;

-- showing countries with highest death count compared to total population 
select location,population,max(total_deaths) as highestdeathcount
from [Covid deaths data]
group by location, population
order by 3 desc;
 
-- as we can see that in result we r having some locations which shouldn't be here and for that we have to add one more line to our queries
select location,population,max(total_deaths) as highestdeathcount
from [Covid deaths data]
where continent is not null
group by location, population
order by 3 desc;

-- now when you run this above query again you will not get that world or income locations anymore

-- LET'S BREAK DOWN THE DATA BY CONTINENT

Select continent,max(population) as totalpopulation,max(total_cases)as totalinfected
from [Covid deaths data]
where continent is not null
group by continent;

-- Showing the continents with the highest death count

Select continent,max(population) as totalpopulation,max(total_cases)as totalinfected, max(total_deaths) as totaldeathcount
from [Covid deaths data]
where continent is not null
group by continent;

-- GLOBAL NUMBERS
Select date,SUM(new_cases)Newcases, SUM(new_deaths)newdeaths
from [Covid deaths data]
where continent is not null
group by date
Order by 1;

Select date,SUM(total_cases)totalcases, SUM(total_deaths)totaldeaths
from [Covid deaths data]
where continent is not null
group by date
Order by 1;

Select SUM(new_cases)Newcases, SUM(new_deaths)newdeaths
from [Covid deaths data]
where continent is not null
group by date
Order by 1;

-- joining tables
select * 
from [covid deaths data] dea
join [Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from [covid deaths data] dea
join [Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- calculating cumulative sum of total vaccinations till date
select dea.location,dea.date,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.date) as csum
from [covid deaths data] dea
join [Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
order by 1,2;


-- using CTE
With populationvsVac (Location, date,population,new_vaccinations, csum)
as
(
select dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.date) as csum
from [covid deaths data] dea
join [Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (csum/population) * 100
from populationvsVac

-- USING TEMPORARY TABLE

Drop table if exists #percentnewtests
create table #percentnewtests
(
continent nvarchar (255),
loaction nvarchar (255),
date datetime,
population numeric,
new_tests nvarchar (255),
testsum numeric)

insert into  #percentnewtests
select continent, location, date, population, new_tests, 
SUM(CAST(new_tests as int)) over (Partition by location order by date) as testsum
from [Covid Vaccination]
select *, (testsum/population) * 100 as testedpeople
from #percentnewtests

-- creating view
create view perecentpopulationvaccinated as 
select dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.date) as csum
from [covid deaths data] dea
join [Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null