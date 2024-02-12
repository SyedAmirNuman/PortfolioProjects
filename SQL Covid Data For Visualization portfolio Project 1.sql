select *
from [project covid]..[covid-data]

--Creating backup first

select *
INTO Backup_CovidData
from [project covid]..[covid-data]

--Cleaining the data 
--deleate row where date is between 2021-08-16 and 2023-11-25

delete
from [project covid]..[covid-data]
where date >= '2021-08-16' and date <= '2023-11-25'

--creating new table Covid-deaths

select iso_code, continent, location, date, population, total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million
into Covid_deaths
from [project covid]..[covid-data]

select *
from [dbo].[Covid_deaths]
order by location, date

--creating new table covid_Vaccination

select *
into covid_Vaccination
from [project covid]..[covid-data]

alter table [dbo].[covid_Vaccination]
drop column total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million


select *
from [dbo].[covid_Vaccination]
order by location, date

-- checking both data

select *
from [dbo].[Covid_deaths]
order by location, date

--select *
--from [dbo].[covid_Vaccination]
--order by location, date

-- select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from [dbo].[Covid_deaths]
order by location, date

--loking at total cases vs total deaths
--showes the likelyhood of dying from covid

select Location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 DeathPercentage
from [dbo].[Covid_deaths]
where location like '%india%' and continent is not null
order by location, date

--Looking at the total cases vs total population
--shows percentage of population got covid

select Location, date, total_cases, population, (total_cases/population)*100 as PositivePercentage
from [dbo].[Covid_deaths]
--where location like '%india%'
order by date

--looking at countries with highest infection rate compare to population

select Location, population, max(cast(total_cases as float)) as highestInfectionCount, max(total_cases/population)*100 as Percentageofinfection
from [dbo].[Covid_deaths]
--where location like '%india%'
where continent is not null
group by location, population
order by Percentageofinfection desc

--showing countries with highest death count per population

select Location, population, max(cast(total_deaths as float)) as TotalDeathCount
from [dbo].[Covid_deaths]
--where location like '%india%'
where continent is not null
group by location, population
order by TotalDeathCount desc

--Let's break things down by continent

--showing continents with the highest death count per population

select continent, max(cast(total_deaths as float)) as TotalDeathCount
from [dbo].[Covid_deaths]
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths , (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage --, (convert(float,total_deaths)/convert(float,total_cases))*100 DeathPercentage
from [dbo].[Covid_deaths]
--where location like '%india%' 
where continent is not null
--group by date
--order by date

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [project covid]..[Covid_deaths] as dea
join [project covid]..[covid_Vaccination] as vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by location, date

--use CTE

with Popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [project covid]..[Covid_deaths] as dea
join [project covid]..[covid_Vaccination] as vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by location, date
)
select *, (rollingpeoplevaccinated/population)*100 percentageofvaccination
from Popvsvac
order by location, date

--use Temp table

drop table if exists #percentofpeoplevaccinated
create table #percentofpeoplevaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
date date,
population float,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #percentofpeoplevaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [project covid]..[Covid_deaths] as dea
join [project covid]..[covid_Vaccination] as vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by location, date

select *, (rollingpeoplevaccinated/population)*100 percentageofvaccination
from #percentofpeoplevaccinated
order by location, date

--looking at the Cardiovasc death rate by Population

select location, population, cardiovasc_death_rate, (cardiovasc_death_rate/population)*100 as DeathByHeartAttackpercentage
from [project covid]..covid_Vaccination
where continent is not null
group by location, population, cardiovasc_death_rate
order by location


--creating view to store data for later visualization

create view percentofpeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [project covid]..[Covid_deaths] as dea
join [project covid]..[covid_Vaccination] as vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

--order by location, date

create view TotalDeathCountByContinent as
select continent, max(cast(total_deaths as float)) as TotalDeathCount
from [dbo].[Covid_deaths]
--where location like '%india%'
where continent is not null
group by continent
--order by TotalDeathCount desc

create view HeartAttackRateincreasedbyInCovid as
select location, population, cardiovasc_death_rate, (cardiovasc_death_rate/population)*100 as DeathByHeartAttackpercentage
from [project covid]..covid_Vaccination
where continent is not null
group by location, population, cardiovasc_death_rate
--order by location






