USE Portfolio_Project;

-- Date range of data in this project is in between 2020-01-01 and 2021-08-15 

--Get know with tables
SELECT  * FROM dbo.Covid_Deaths;
SELECT  * FROM dbo.Vaccine_Details;

--Lets check covid details of Baltic country Latvia.

SELECT location as Country,
Date,
Population,
New_Cases,
ROUND((New_Cases/Population)*100,4) as Perc_New_Cases_Per_population,
New_Deaths,
ROUND((CAST(New_Deaths AS INT)/Population)*100,4) AS Perc_New_Deaths_Per_Population
from dbo.Covid_Deaths
WHERE location='Latvia' and continent is not null
ORDER BY 2

--Use window function to find running total of new cases and new deaths 

SELECT location as Country,
Date,
Population,
New_Cases,
SUM(New_Cases) OVER ( ORDER BY Date) as Running_Total_New_Cases,
ROUND((SUM(New_Cases) OVER ( ORDER BY Date)/Population)*100,4) as Perc_Total_Cases_Per_population,
New_Deaths,
SUM(CAST(New_Deaths AS INT)) OVER ( ORDER BY Date) as Running_Total_Deaths,
ROUND((SUM(CAST(New_Deaths AS INT)) OVER ( ORDER BY Date)/Population)*100,4) AS Perc_Total_Deaths_Per_Population
from dbo.Covid_Deaths
WHERE location='Latvia' and continent is not null
ORDER BY 2

--Find out top 20 infected days in Latvia using ROW_NUMBER function

SELECT * FROM
(SELECT 
location as Country,
Date,
Population,
New_Cases,
ROW_NUMBER() OVER( ORDER BY New_Cases DESC) AS Top_Infected_Days
from dbo.Covid_Deaths
WHERE location='Latvia' and continent is not null)A
WHERE Top_Infected_Days<=20

--Top 20 days with high deaths in Latvia using DENSE_RANK function

SELECT * FROM
(SELECT 
location as Country,
Date,
Population,
New_Deaths,
DENSE_RANK() OVER(ORDER BY CAST(New_Deaths AS INT) DESC) AS Top_Death_Count
from dbo.Covid_Deaths
WHERE location='Latvia' and continent is not null)A
WHERE Top_Death_Count<=20;

--Details about vaccination in Latvia
SELECT location as Country,
Date,
Population,
New_Vaccinations
FROM dbo.Vaccine_Details
WHERE location='Latvia'
and continent IS NOT NULL
ORDER BY 2

--Running total of vaccinations in Latvia

SELECT location as Country,
Date,
Population,
New_Vaccinations,
SUM(CAST(New_Vaccinations AS INT)) OVER(ORDER BY Date) as Running_Total_Vaccinations,
ROUND(SUM(CAST(New_Vaccinations AS INT)) OVER(ORDER BY Date)/Population,4)*100 AS Vaccination_Per_Population_In_Percentage
FROM dbo.Vaccine_Details
WHERE location='Latvia'
and continent IS NOT NULL
ORDER BY 2;

--Top 30 Vaccinated days

SELECT * FROM
(SELECT location as Country,
Date,
Population,
New_Vaccinations,
DENSE_RANK() OVER(ORDER BY CAST(New_Vaccinations AS INT) DESC) Top_Vaccinated_days
FROM dbo.Vaccine_Details
WHERE location='Latvia'
and continent IS NOT NULL) A
WHERE Top_Vaccinated_days<=30
ORDER BY Top_Vaccinated_days;


--Compare new deaths from 2020-12-27 to 2021-02-10 (where most of death cases recorded in Latvia) 
--and 2021-07-01 to 2021-08-15 (1 month after most of people vaccinated in Latvia) and find out how vaccination effect in new death cases.
-- Or it is a 46 days comparison before and after highly vaccinated

--Use CTEs to compare those 46 days as mentioned above

WITH Before_Highly_Vaccinated AS
(
SELECT
Status='Before_Highly_Vaccinated',
New_Deaths 
FROM dbo.Covid_Deaths
WHERE Date BETWEEN '2020-12-27' AND '2021-02-10'
AND location='Latvia'
AND continent IS NOT NULL
),
After_Highly_Vaccinated AS
(
SELECT 
Status='After_Highly_Vaccinated',
New_Deaths 
FROM dbo.Covid_Deaths
WHERE Date BETWEEN '2021-07-01' AND '2021-08-15'
AND location='Latvia'
AND continent IS NOT NULL
),
Union_Table as 
(SELECT *
FROM Before_Highly_Vaccinated
UNION ALL
SELECT *
FROM After_Highly_Vaccinated)
SELECT Status,SUM(CAST(New_Deaths AS INT)) AS Total_Deaths
FROM Union_Table
GROUP BY Status

--Deatails and comparison of Covid stats between 3 Baltic countries(Latvia,Lithuania,Estonia)

--Create temporary table for Latvia

CREATE TABLE #Latvia
(
Country VARCHAR(30),
Date DATE,
Population FLOAT,
New_Cases FLOAT,
Running_Total_Cases INT,
Cases_Per_Population_Percentage FLOAT,
New_Deaths VARCHAR(30),
Running_Total_Deaths INT,
Death_Rate_Per_Population_Percentage FLOAT,
People_Fully_Vaccinated VARCHAR(30),
People_Fully_Vaccinated_Previous INT,
New_Fully_Vaccinated INT,
Fully_Vaccinated_Per_Population_Percentage FLOAT
)

INSERT INTO #Latvia
(
Country,
Date,
Population,
New_Cases,
Running_Total_Cases,
Cases_Per_Population_Percentage,
New_Deaths,
Running_Total_Deaths,
Death_Rate_Per_Population_Percentage,
People_Fully_Vaccinated,
People_Fully_Vaccinated_Previous,
New_Fully_Vaccinated,
Fully_Vaccinated_Per_Population_Percentage
)
SELECT 
a.Location,
a.Date,
a.Population,
a.New_Cases,
SUM(a.New_Cases) OVER(ORDER BY a.Date) AS Running_Total_Cases,
ROUND(SUM(a.New_Cases) OVER(ORDER BY a.Date)/a.Population,4)*100 AS Cases_Per_Population_Percentage,
a.New_Deaths,
SUM(CAST(a.New_Deaths AS INT)) OVER(ORDER BY a.Date) AS Running_Total_Deaths,
ROUND(SUM(CAST(a.New_Deaths AS INT)) OVER(ORDER BY a.Date)/a.Population,4)*100 AS Death_Rate_Per_Population_Percentage,
b.people_fully_vaccinated,
LAG(CAST(b.people_fully_vaccinated AS INT)) OVER (ORDER BY b.Date) AS People_Fully_Vaccinated_Previous ,
CAST(b.people_fully_vaccinated AS INT)-LAG(CAST(b.people_fully_vaccinated AS INT)) OVER (ORDER BY b.Date) AS New_Fully_Vaccinated,
ROUND(CAST(b.people_fully_vaccinated AS INT)/b.Population,4)*100 AS Total_Vaccinated_Per_Population_Percentage
FROM Covid_Deaths a
INNER JOIN Vaccine_Details b
ON b.Date=a.Date
AND b.Location=a.Location 
WHERE a.location='Latvia'
and a.continent IS NOT NULL;


--Create temporary table for Lithuania

CREATE TABLE #Lithuania
(
Country VARCHAR(30),
Date DATE,
Population FLOAT,
New_Cases FLOAT,
Running_Total_Cases INT,
Cases_Per_Population_Percentage FLOAT,
New_Deaths VARCHAR(30),
Running_Total_Deaths INT,
Death_Rate_Per_Population_Percentage FLOAT,
People_Fully_Vaccinated VARCHAR(30),
People_Fully_Vaccinated_Previous INT,
New_Fully_Vaccinated INT,
Fully_Vaccinated_Per_Population_Percentage FLOAT
)

INSERT INTO #Lithuania
(
Country,
Date,
Population,
New_Cases,
Running_Total_Cases,
Cases_Per_Population_Percentage,
New_Deaths,
Running_Total_Deaths,
Death_Rate_Per_Population_Percentage,
People_Fully_Vaccinated,
People_Fully_Vaccinated_Previous,
New_Fully_Vaccinated,
Fully_Vaccinated_Per_Population_Percentage
)
SELECT 
a.Location,
a.Date,
a.Population,
a.New_Cases,
SUM(a.New_Cases) OVER(ORDER BY a.Date) AS Running_Total_Cases,
ROUND(SUM(a.New_Cases) OVER(ORDER BY a.Date)/a.Population,4)*100 AS Cases_Per_Population_Percentage,
a.New_Deaths,
SUM(CAST(a.New_Deaths AS INT)) OVER(ORDER BY a.Date) AS Running_Total_Deaths,
ROUND(SUM(CAST(a.New_Deaths AS INT)) OVER(ORDER BY a.Date)/a.Population,4)*100 AS Death_Rate_Per_Population_Percentage,
b.people_fully_vaccinated,
LAG(CAST(b.people_fully_vaccinated AS INT)) OVER (ORDER BY b.Date) AS People_Fully_Vaccinated_Previous ,
CAST(b.people_fully_vaccinated AS INT)-LAG(CAST(b.people_fully_vaccinated AS INT)) OVER (ORDER BY b.Date) AS New_Fully_Vaccinated,
ROUND(CAST(b.people_fully_vaccinated AS INT)/b.Population,4)*100 AS Total_Vaccinated_Per_Population_Percentage
FROM Covid_Deaths a
INNER JOIN Vaccine_Details b
ON b.Date=a.Date
AND b.Location=a.Location 
WHERE a.location='Lithuania'
and a.continent IS NOT NULL;


--Create temporary table for Estonia

CREATE TABLE #Estonia
(
Country VARCHAR(30),
Date DATE,
Population FLOAT,
New_Cases FLOAT,
Running_Total_Cases INT,
Cases_Per_Population_Percentage FLOAT,
New_Deaths VARCHAR(30),
Running_Total_Deaths INT,
Death_Rate_Per_Population_Percentage FLOAT,
People_Fully_Vaccinated VARCHAR(30),
People_Fully_Vaccinated_Previous INT,
New_Fully_Vaccinated INT,
Fully_Vaccinated_Per_Population_Percentage FLOAT
)

INSERT INTO #Estonia
(
Country,
Date,
Population,
New_Cases,
Running_Total_Cases,
Cases_Per_Population_Percentage,
New_Deaths,
Running_Total_Deaths,
Death_Rate_Per_Population_Percentage,
People_Fully_Vaccinated,
People_Fully_Vaccinated_Previous,
New_Fully_Vaccinated,
Fully_Vaccinated_Per_Population_Percentage
)
SELECT 
a.Location,
a.Date,
a.Population,
a.New_Cases,
SUM(a.New_Cases) OVER(ORDER BY a.Date) AS Running_Total_Cases,
ROUND(SUM(a.New_Cases) OVER(ORDER BY a.Date)/a.Population,4)*100 AS Cases_Per_Population_Percentage,
a.New_Deaths,
SUM(CAST(a.New_Deaths AS INT)) OVER(ORDER BY a.Date) AS Running_Total_Deaths,
ROUND(SUM(CAST(a.New_Deaths AS INT)) OVER(ORDER BY a.Date)/a.Population,4)*100 AS Death_Rate_Per_Population_Percentage,
b.people_fully_vaccinated,
LAG(CAST(b.people_fully_vaccinated AS INT)) OVER (ORDER BY b.Date) AS People_Fully_Vaccinated_Previous ,
CAST(b.people_fully_vaccinated AS INT)-LAG(CAST(b.people_fully_vaccinated AS INT)) OVER (ORDER BY b.Date) AS New_Fully_Vaccinated,
ROUND(CAST(b.people_fully_vaccinated AS INT)/b.Population,4)*100 AS Total_Vaccinated_Per_Population_Percentage
FROM Covid_Deaths a
INNER JOIN Vaccine_Details b
ON b.Date=a.Date
AND b.Location=a.Location 
WHERE a.location='Estonia'
and a.continent IS NOT NULL;

--Create Summary of Covid related records between Baltic Countries

CREATE TABLE #Summary_Table
(
Country VARCHAR(30),
Date DATE,
Population FLOAT,
New_Cases FLOAT,
Running_Total_Cases INT,
Cases_Per_Population_Percentage FLOAT,
New_Deaths VARCHAR(30),
Running_Total_Deaths INT,
Death_Rate_Per_Population_Percentage FLOAT,
People_Fully_Vaccinated VARCHAR(30),
People_Fully_Vaccinated_Previous INT,
New_Fully_Vaccinated INT,
Fully_Vaccinated_Per_Population_Percentage FLOAT
)
INSERT INTO #Summary_Table
(
Country,
Date,
Population,
New_Cases,
Running_Total_Cases,
Cases_Per_Population_Percentage,
New_Deaths,
Running_Total_Deaths,
Death_Rate_Per_Population_Percentage,
People_Fully_Vaccinated,
People_Fully_Vaccinated_Previous,
New_Fully_Vaccinated,
Fully_Vaccinated_Per_Population_Percentage
)
SELECT * FROM #Latvia
UNION ALL
SELECT * FROM #Lithuania
UNION ALL
SELECT * FROM #Estonia

--Create STORED PROCEDURE with varibale 'Country_Number' to choose country.
--0 for Latvia
--1 for Lithuania
--2 for Estonia
--3 for Summary of Baltic countries

CREATE PROCEDURE dbo.Baltic_Countries(@Country_Number INT)
AS
BEGIN
  IF @Country_Number=0
  BEGIN
      SELECT * FROM #Latvia
	  ORDER BY Date
  END 
  IF @Country_Number=1
  BEGIN
      SELECT * FROM #Lithuania
	  ORDER BY Date
  END
  IF @Country_Number=2
  BEGIN
      SELECT * FROM #Estonia
	  ORDER BY Date
  END
  IF @Country_Number=3
  BEGIN
      SELECT Country,
      Population,SUM(New_Cases) AS Total_Cases,ROUND((SUM(New_Cases)/Population),4)*100 AS Total_Cases_Per_Population,
      SUM(CAST(New_Deaths AS INT)) AS Total_Deaths,ROUND(SUM(CAST(New_Deaths AS INT))/Population,4)*100 AS Total_Deaths_Per_population,
      SUM(New_Fully_Vaccinated) AS Total_Fully_Vaccinated,
      ROUND(SUM(New_Fully_Vaccinated)/Population,4)*100 AS Total_Fully_Vaccinated_Population
	  FROM #Summary_Table
	  GROUP BY Country,Population
  END

END



































