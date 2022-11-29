
/* Data Exploration 
 Getting to know the data*/

select * from CovidDeaths order by location,date
select * from CovidVaccinations order by location,date

select location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths where continent is not null
order by location,date

select Location,max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths where continent is null
group by location
order by Total_Death_Count desc

-- Total Cases VS Total Deaths- May 2021

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths where continent is not null
order by location,date

-- Total Cases VS Total Deaths in United States(May 2021)

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths where location like '%states%' and  continent is not null
order by location,date

--Total cases VS Population

select location,date,total_cases,population,(total_cases/population)*100 as Population_Percentage
from CovidDeaths where location like '%states%' and  continent is not null
order by location,date

--Countries with highest infection Rate Compared to Population.

select location,population,max(total_cases) as Highest_infection_count,max((total_cases/population)*100) as Population_infected_Percentage
from CovidDeaths where continent is not null
group by location,population
order by Population_infected_Percentage desc

--Countries with highest Death Count percentage

select location,max(cast(total_deaths as int) ) as Higest_Total_death
from CovidDeaths where continent is not null
group by location,population
order by Higest_Total_death desc

---Group By Continent

select continent, max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths where continent is not null
group by continent
order by Total_Death_Count desc


-- Global Numbers

--Global Death Percentage by date

select date,Sum(new_cases) as Cases,Sum(cast(new_deaths as int)) as Deaths,Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths where  continent is not null
group by date
order by date,Cases

-- Global Death Percentage

select Sum(new_cases) as Cases,Sum(cast(new_deaths as int)) as Deaths,Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths where  continent is not null

-- Covid Death and Vaccinations

select * 
from CovidDeaths as death
join CovidVaccinations as vac
on death.location= vac.location and death.date= vac.date

--- Total population vs total vacinations

select death.continent,death.location,death.population,death.date,vac.total_vaccinations
from CovidDeaths as death
join CovidVaccinations as vac 
on death.location= vac.location and death.date= vac.date 
where death.continent is not null

-- new vaccination per day(rolloing count)
select death.continent,death.location,death.population,death.date,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by death.location order by death.location, death.date) as Rolling_vaccination
from CovidDeaths as death
join CovidVaccinations as vac 
on death.location= vac.location and death.date= vac.date 
where death.continent is not null
order by death.location,death.date

--Population vs total vacinations

--- CTE

With Pop_Vac_CTE(Continent,location,population,date,new_vaccinations,Rolling_Vaccination)
as
(
	select death.continent,death.location,death.population,death.date,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over(partition by death.location order by death.location, death.date) as Rolling_vaccination
	from CovidDeaths as death
	join CovidVaccinations as vac 
	on death.location= vac.location and death.date= vac.date 
	where death.continent is not null

)
select location,population,date,new_vaccinations,Rolling_Vaccination ,(Rolling_Vaccination/population)*100 as Percentage_vaccination

from Pop_Vac_CTE


--- TEMP TABLE

DROP TABLE IF EXISTS #PercentageVaccination

CREATE TABLE  #PercentageVaccination
(
continent nvarchar(200),
location nvarchar(200),
population numeric,
date datetime,
new_vaccinations numeric, 
Rolling_Vaccination numeric
)
INSERT INTO  #PercentageVaccination 

	select 
	death.continent,
	death.location,
	death.population,
	death.date,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over(partition by death.location order by death.location, death.date) as Rolling_vaccination
	from CovidDeaths as death
	join CovidVaccinations as vac 
	on death.location= vac.location and death.date= vac.date 
	where death.continent is not null
	
SELECT * ,(Rolling_Vaccination/population)*100 as Percentage_vaccination
from #PercentageVaccination

--- VIEW to store data for Vizualisations

Create View PercentageVaccination 
as
	select 
	death.continent,death.location,death.population,death.date,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over(partition by death.location order by death.location, death.date) as Rolling_vaccination
	from CovidDeaths as death
	join CovidVaccinations as vac 
	on death.location= vac.location and death.date= vac.date 
	where death.continent is not null

select * from PercentageVaccination