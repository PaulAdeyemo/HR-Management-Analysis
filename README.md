# HR-Management-Analysis using SQL 

## Aim of Project

The aim of this project is to delve into data analysis using SQL to uncover insights for HR department and visualise  the results using Power BI in other to make an informed decisions and strategic workforce planning.

### Data Source
The data source is attached in the repository which contains records of employees from 2000 to 2020.

### Tools
- SQL server to uncover insights.
- Power BI for Visualisation.

### Data Cleaning/Preparation
The following was done using SQL server; 
1. Data Loading and Inspection.
2. Handling Missing Values.
3. Data Cleaning and Formatting.

### Exploratory Data Analysis

1. How have employee hire counts varied over time?
 ``` sql

   SELECT hire_year,hires,terminations,
hires - terminations as net_change,
ROUND(CAST((hires- terminations) AS FLOAT)/hires,2)* 100 AS percent_hire_change
FROM(SELECT year(hire_date) as hire_year,count(*) as hires,
SUM(CASE WHEN new_termdate is not null and new_termdate<=GETDATE() THEN 1 ELSE 0 END) AS terminations
FROM hr_dataGROUP BY year(hire_date)) as sub_queryorder by percent_hire_change desc
```
2. What is the age distribution in the Company?
 ``` sql

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
WHEN age>=22 AND age<= 30 THEN '21 TO 30'
WHEN age>=31 AND age<= 40 THEN '31 TO 40'
WHEN age>=41 AND age<= 50 THEN '41 TO 50'
ELSE '50+'
END AS age_group,
gender
FROM hr_data
WHERE new_termdate IS NULL) AS sub_query
GROUP BY age_group,gender
ORDER BY age_group,gender;
```
3. What is the gender breakdown in the Company?
``` sql
SELECT gender,
count(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;
```
4. How many employees work remotely for each department?
``` sql
SELECT location,
count(*) as count,
department
FROM hr_data
WHERE new_termdate IS null and location='Remote'
GROUP BY location,department;
```
5. What is the race distribution in the Company?
 ``` sql
   SELECT race,
count(*) AS count
FROM hr_data
WHERE new_termdate is NULL 
GROUP BY race 
ORDER BY count DESC; 
```
6. Which department has the highest turnover rate?
 ``` sql
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
```
7. What is the average lenght of employment in the company?
``` sql
SELECT
AVG(DATEDIFF(year,hire_date,new_termdate)) AS TENURE
FROM hr_data
WHERE new_termdate is NOT NULL AND new_termdate<=GETDATE();
```
8. What is the tenure distribution for each department?
``` sql
SELECT
department,
AVG(DATEDIFF(year,hire_date,new_termdate)) AS TENURE
FROM hr_data
WHERE new_termdate is NOT NULL AND new_termdate<=GETDATE()
GROUP BY department 
ORDER BY tenure DESC;
```
9.What is the distribution of employee across different states?

```sql
SELECT location_state,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL 
GROUP BY location_state
ORDER BY count DESC;
```
### Findings
1. There is a significant increase of employee counts over the years. 2020 experienced approximately 100% in employee count.
2. Across all age range, there are more male employees than female or non-conforming employees.
3. The gender are almost evenly distributed across all department. However, there are slightly more male employees with approximately 51%.Non-conforming pulled 3% in total employee.
4. Remote employees makes approximately 25% of the total number of employee. Engineering department had the highest remote employee with 29.5% while Auditing department pulled the least with <1% of Remote employee.
5. White employees pulled the highest number of employee with 28% of total employee, followed by mixed race making approximately 17%, black, Asian with, Hispanic/Latino while Native Hawaiian pulled the least percentage of approximately 6% of total employee .
6. Auditing department has the highest turnover rate  with 12%,while Legal, Sales, Support, and Training have the same turn-over rate with 9% while Business development, engineering, human resource marketing and services had the lowest turn-over rate.
7. Majority of employees are located in Ohio contributing 81% to the total number of employee followed by Pennsylvania with 5% and Illinois, Indiana, Michigan, Kentucky and Wisconsin pulling the least number of employee.
