CREATE DATABASE hr;
USE hr;
SELECT *
FROM hr_data;

SELECT termdate
FROM hr_data
ORDER BY termdate DESC;

UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME,LEFT(termdate,19), 120),'yyyy-mm-dd')

ALTER TABLE hr_data
ADD new_termdate DATE;

-- copy converted time values from termdate to new_termdate

UPDATE hr_data
SET new_termdate = CASE
WHEN termdate IS NOT NULL AND ISDATE(termdate)=1 
THEN CAST(termdate AS DATETIME)
ELSE NULL 
END;

-- create new column "age"
ALTER TABLE hr_data
ADD age nvarchar(50);

-- populate the new column "age"
UPDATE hr_data
SET age = DATEDIFF(YEAR,birthdate,GETDATE());

-- QUESTIONS TO ANSWER FROM THE DATA

--1. WHAT IS THE AGE DISTRIBUTION IN THE COMPANY? 

-- age group distribution 

SELECT min(age) as youngest,
max(age) as oldest
from hr_data

-- age group by gender
SELECT age_group,
count(*) as count_,
gender
FROM
(SELECT  
CASE 
WHEN age<=22 AND age<= 30 THEN '21 TO 30'
WHEN age<=31 AND age<= 40 THEN '31 TO 40'
WHEN age<=41 AND age<= 50 THEN '41 TO 50'
ELSE '50+'
END AS age_group,
gender
FROM hr_data
WHERE new_termdate IS NULL) AS sub_query
GROUP BY age_group,gender
ORDER BY age_group,gender;




-- 2 WHAT IS THE GENDER BREAKDOWN IN THE COMPANY?

SELECT gender,
count(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;
--3 HOW DOES GENDER VARY ACROSS DEPARTMENTS AND JOB TITLES?

-- department
SELECT count(gender) AS count,
department,
gender
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department,gender
ORDER BY department,gender ASC;

-- job titles
SELECT count(gender) AS count,
jobtitle,
department,
gender
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle,gender,department
ORDER BY jobtitle,gender,department ASC;


--4 WHAT IS THE RACE DISTRIBUTION IN THE COMPANY?

SELECT race,
count(*) AS count
FROM hr_data
WHERE new_termdate is NULL 
GROUP BY race 
ORDER BY count DESC; 
--5 WHAT IS THE AVERAGE LENGTH OF EMPLOYEMENT IN THE COMPANY?

SELECT
AVG(DATEDIFF(year,hire_date,new_termdate)) AS TENURE
FROM hr_data
WHERE new_termdate is NOT NULL AND new_termdate<=GETDATE();

--6 WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE?

--get the total count
SELECT 
department,
total_count,
terminated_count,
ROUND((CAST(terminated_count AS FLOAT)/total_count),2)* 100 as turnover_rate
FROM 
(SELECT department,
count(*) AS total_count,
SUM(CASE
WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminated_count
FROM hr_data
GROUP BY department) as sub_query
ORDER BY turnover_rate desc
-- get the terminated count
-- terminated count/total count

--7 WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT?
SELECT
department,
AVG(DATEDIFF(year,hire_date,new_termdate)) AS TENURE
FROM hr_data
WHERE new_termdate is NOT NULL AND new_termdate<=GETDATE()
GROUP BY department 
ORDER BY tenure DESC;

--8 HOW MANY EMPLOYEES WORK REMOTELY FOR EACH DEPARTMENT?
SELECT location,
count(*) as count,
department
FROM hr_data
WHERE new_termdate IS null and location='Remote'
GROUP BY location,department;

--9 WHAT IS THE DISTRIBUTION OF EMPLOYEE ACROSS DIFFERENT STATES?

SELECT location_state,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL 
GROUP BY location_state
ORDER BY count DESC;
--10 HOW ARE JOB TITLES DISTRIBUTED IN THE COMPANY

SELECT jobtitle,
count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC
--11 HOW HAVE EMPLOYEE HIRE COUNTS VARIED OVER TIME?
-- calculate hires
-- calculate terminations
-- (hires-terminations)/hires   percent hire change

SELECT
hire_year,
hires,
terminations,
hires - terminations as net_change,
ROUND(CAST((hires- terminations) AS FLOAT)/hires,2)* 100 AS percent_hire_change
FROM
(SELECT year(hire_date) as hire_year,
count(*) as hires,
SUM(CASE 
WHEN new_termdate is not null and new_termdate<=GETDATE() THEN 1 ELSE 0 
END) AS terminations
FROM hr_data
GROUP BY year(hire_date)) as sub_query
order by percent_hire_change desc