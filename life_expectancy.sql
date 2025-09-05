ALTER TABLE life_2014 MODIFY Country VARCHAR(100) NOT NULL;
ALTER TABLE life_2014 ADD PRIMARY KEY (Country);

ALTER TABLE suicides_2014 MODIFY Country VARCHAR(100) NOT NULL;

ALTER TABLE suicides_2014
ADD CONSTRAINT fk_country
FOREIGN KEY (Country) REFERENCES life_2014(Country);

SELECT DISTINCT s.Country
FROM suicides_2014 s
LEFT JOIN life_2014 l ON s.Country = l.Country
WHERE l.Country IS NULL;

DELETE FROM suicides_2014
WHERE Country NOT IN (SELECT Country FROM life_2014);

ALTER TABLE lifeexpectancy
ADD COLUMN Region VARCHAR(50);

UPDATE lifeexpectancy
SET Region = CASE 
    WHEN Country IN ('Algeria', 'Angola', 'Benin', 'Botswana', 'Burkina Faso', 'Burundi', 'Cameroon', 'Cape Verde', 
                         'Central African Republic', 'Chad', 'Comoros', 'Congo', 'Côte d\'Ivoire', 'DR Congo', 'Egypt',
                         'Equatorial Guinea', 'Eritrea', 'Ethiopia', 'Gabon', 'Gambia', 'Ghana', 'Guinea', 'Guinea-Bissau',
                         'Kenya', 'Lesotho', 'Liberia', 'Libya', 'Madagascar', 'Malawi', 'Mali', 'Mauritania', 'Mauritius',
                         'Morocco', 'Mozambique', 'Namibia', 'Niger', 'Nigeria', 'Rwanda', 'Senegal', 'Seychelles',
                         'Sierra Leone', 'Somalia', 'South Africa', 'South Sudan', 'Sudan', 'Swaziland', 'Tanzania',
                         'Togo', 'Tunisia', 'Uganda', 'Zambia', 'Zimbabwe') THEN 'Africa'
    WHEN Country IN ('Afghanistan', 'Armenia', 'Azerbaijan', 'Bahrain', 'Bangladesh', 'Bhutan', 'Brunei', 'Cambodia',
                        'China', 'Cyprus', 'Georgia', 'India', 'Indonesia', 'Iran', 'Iraq', 'Israel', 'Japan', 'Jordan',
                        'Kazakhstan', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Lebanon', 'Malaysia', 'Maldives', 'Mongolia',
                        'Myanmar', 'Nepal', 'North Korea', 'Oman', 'Pakistan', 'Palestine', 'Philippines', 'Qatar',
                        'Saudi Arabia', 'Singapore', 'South Korea', 'Sri Lanka', 'Syria', 'Taiwan', 'Tajikistan',
                        'Thailand', 'Timor-Leste', 'Turkey', 'Turkmenistan', 'UAE', 'Uzbekistan', 'Vietnam', 'Yemen') THEN 'Asia'
    WHEN Country IN ('Albania', 'Andorra', 'Austria', 'Belarus', 'Belgium', 'Bosnia and Herzegovina', 'Bulgaria',
                        'Croatia', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece',
                        'Hungary', 'Iceland', 'Ireland', 'Italy', 'Latvia', 'Liechtenstein', 'Lithuania', 'Luxembourg',
                        'Malta', 'Moldova', 'Monaco', 'Montenegro', 'Netherlands', 'North Macedonia', 'Norway', 'Poland',
                        'Portugal', 'Romania', 'Russia', 'San Marino', 'Serbia', 'Slovakia', 'Slovenia', 'Spain',
                        'Sweden', 'Switzerland', 'Ukraine', 'UK', 'Vatican City') THEN 'Europe'
    WHEN Country IN ('Argentina', 'Bolivia', 'Brazil', 'Chile', 'Colombia', 'Ecuador', 'Guyana', 'Paraguay', 'Peru',
                        'Suriname', 'Uruguay', 'Venezuela') THEN 'South America'
    WHEN Country IN ('Antigua and Barbuda','Bahamas','Barbados','Belize','Canada','Costa Rica','Cuba',
                        'Dominica','Dominican Republic','El Salvador','Grenada','Guatemala','Haiti','Honduras',
                        'Jamaica','Mexico','Nicaragua','Panama','Saint Lucia','Saint Vincent and the Grenadines',
                        'Trinidad and Tobago','United States') THEN 'North America'
    WHEN Country IN ('Australia','Fiji','Kiribati','Marshall Islands','Micronesia','Nauru','New Zealand',
                        'Palau','Papua New Guinea','Samoa','Solomon Islands','Tonga','Tuvalu','Vanuatu') THEN 'Oceania'
    ELSE 'Other'
END;


select * from lifeexpectancy
where region = 'other';

SELECT 
  Region, 
  ROUND(AVG(Life_expectancy), 2) AS avg_life_expectancy,
  ROUND(AVG(GDP), 2) AS avg_GDP
FROM lifeexpectancy
GROUP BY Region
ORDER BY avg_life_expectancy desc;

ALTER TABLE lifeexpectancy
ADD COLUMN country_year VARCHAR(100);
FOREIGN KEY (Country) REFERENCES life_2014(Country);

UPDATE lifeexpectancy
SET country_year = CONCAT(Country, '_', Year);

ALTER TABLE life_2014
ADD COLUMN country_year VARCHAR(100);
UPDATE life_2014
SET country_year = CONCAT(Country, '_', Year);

ALTER TABLE lifeexpectancy ADD PRIMARY KEY (country_year);

ALTER TABLE life_2014
ADD CONSTRAINT fk_country_year
FOREIGN KEY (country_year) REFERENCES lifeexpectancy(country_year);

ALTER TABLE suicide
ADD COLUMN country_year VARCHAR(100);

UPDATE suicide
SET country_year = CONCAT(Country, '_', Year);

ALTER TABLE suicide ADD PRIMARY KEY (country_year);

ALTER TABLE suicides_2014
ADD COLUMN country_year VARCHAR(100);

UPDATE suicides_2014
SET country_year = CONCAT(Country, '_', Year);

ALTER TABLE suicides_2014
ADD CONSTRAINT fk_country_year
FOREIGN KEY (country_year) REFERENCES suicide(country_year);


DELETE FROM suicides_2014
WHERE country_year NOT IN (SELECT country_year FROM suicide);

SHOW INDEX FROM suicide;

ALTER TABLE suicide 
drop column country_year;

ALTER TABLE suicides_2014
ADD CONSTRAINT fk_country_year
FOREIGN KEY (country_year) REFERENCES suicide(country_year);


SELECT 
    l.Country,
    l.Life_expectancy,
    ROUND(s.total_suicides / l.population * 100000, 2) AS suicides_per_100k
FROM life_2014 l
JOIN suicides_2014 s 
  ON l.country_year = s.country_year
WHERE l.population > 0
ORDER BY suicides_per_100k DESC;

-- Tuổi thọ trung bình theo quốc gia
SELECT 
  Country, 
  ROUND(AVG(Life_expectancy), 2) AS avg_life_expectancy
FROM lifeexpectancy
GROUP BY Country
ORDER BY avg_life_expectancy desc
limit 10;


-- Tuổi thọ trung bình và GDP theo năm (toàn cầu)
SELECT 
  Year, 
  ROUND(AVG(Life_expectancy), 2) AS avg_life_expectancy,
  ROUND(AVG(GDP), 2) AS avg_GDP
FROM lifeexpectancy
GROUP BY Year
ORDER BY Year;

DELETE FROM lifeexpectancy
WHERE Year = 2015;

-- So sánh tuổi thọ trung bình theo nhóm nước (phát triển / đang phát triển)
SELECT 
  Country, 
  Life_expectancy
FROM lifeexpectancy
WHERE Year = (SELECT MAX(Year) FROM lifeexpectancy)
ORDER BY Life_expectancy DESC
LIMIT 10;

-- Quan hệ GDP và tuổi thọ (top nước GDP cao nhất)
SELECT 
  Country, 
  GDP, 
  Life_expectancy
FROM lifeexpectancy
WHERE Year = (SELECT MAX(Year) FROM lifeexpectancy)
ORDER BY GDP DESC
LIMIT 10;

-- Top 10 quốc gia GDP cao nhất năm 2014
SELECT 
  Country,
  GDP
FROM lifeexpectancy
WHERE year = '2014'
ORDER BY GDP DESC
LIMIT 10;

-- Top 10 quốc gia tuổi thọ cao nhất năm 2014
SELECT 
  Country,
  Life_expectancy
FROM lifeexpectancy
WHERE year = '2014'
ORDER BY Life_expectancy DESC
LIMIT 10;

-- Tương quan giữa GDP với tuổi thọ
SELECT 
  CASE 
    WHEN GDP >= 10000 THEN 'High GDP'
    WHEN GDP BETWEEN 2000 AND 10000 THEN 'Medium GDP'
    ELSE 'Low GDP'
  END AS GDP_Group,
  CASE 
    WHEN ROUND(AVG(Life_expectancy), 2) >= 75 THEN 'High Life Expectancy'
    WHEN ROUND(AVG(Life_expectancy), 2) >= 65 THEN 'Medium Life Expectancy'
    ELSE 'Low Life Expectancy'
  END AS Life_Expectancy_Group,
  ROUND(AVG(Life_expectancy), 2) AS Avg_Life_Expectancy,
  COUNT(*) AS Country_Count
FROM lifeexpectancy
WHERE year = 2014
GROUP BY GDP_Group
ORDER BY 
  CASE GDP_Group
    WHEN 'High GDP' THEN 1
    WHEN 'Medium GDP' THEN 2
    WHEN 'Low GDP' THEN 3
  END;

-- Tương quan giữa học vấn với tuổi thọ
SELECT 
  Country, 
  ROUND(AVG(Schooling), 2) AS avg_schooling,
  ROUND(AVG(Life_expectancy), 2) AS avg_life_expectancy
FROM lifeexpectancy
GROUP BY Country
ORDER BY avg_schooling DESC
LIMIT 10;

-- So sánh các chỉ số tích cực giữa nhóm nước phát triển vs đang phát triển
With A as (
SELECT 
    Country,
    Year,
    GDP,
    percentage_expenditure,
    (GDP * (percentage_expenditure / 100)) AS Total_health_expenditure
FROM lifeexpectancy)
SELECT 
  Status,
  ROUND(AVG(Life_expectancy), 2) AS avg_life_expectancy,
  ROUND(AVG(GDP), 2) AS avg_gdp,
  ROUND(AVG(Schooling), 2) AS avg_schooling,
  ROUND(AVG(Total_health_expenditure), 2) AS avg_health_expenditure,
  ROUND(AVG(Income_composition_of_resources), 2) AS avg_income_composition,
  ROUND(AVG(Diphtheria), 2) AS avg_Diphtheria,
  ROUND(AVG(Hepatitis_B), 2) AS avg_Hepatitis_B,
  ROUND(AVG(Polio), 2) AS avg_Polio
FROM lifeexpectancy
where year = '2014'
GROUP BY Status;

WITH A AS (
    SELECT 
        Country,
        Year,
        GDP,
        percentage_expenditure,
        (GDP * (percentage_expenditure / 100)) AS Total_health_expenditure
    FROM lifeexpectancy
    WHERE Year = 2014
)
SELECT 
    B.Status,
    ROUND(AVG(B.Life_expectancy), 2) AS avg_life_expectancy,
    ROUND(AVG(B.GDP), 2) AS avg_gdp,
    ROUND(AVG(B.Schooling), 2) AS avg_schooling,
    ROUND(AVG(A.Total_health_expenditure), 2) AS avg_health_expenditure,
    ROUND(AVG(B.Income_composition_of_resources), 2) AS avg_income_composition,
    ROUND(AVG(B.Diphtheria), 2) AS avg_Diphtheria,
    ROUND(AVG(B.Hepatitis_B), 2) AS avg_Hepatitis_B,
    ROUND(AVG(B.Polio), 2) AS avg_Polio
FROM lifeexpectancy B
JOIN A ON B.Country = A.Country AND B.Year = A.Year
WHERE B.Year = 2014
GROUP BY B.Status;


-- So sánh các chỉ số tiêu cực giữa nhóm nước phát triển vs đang phát triển
SELECT 
    Country, 
    ROUND(AVG(Life_expectancy), 2) AS avg_life_expectancy,
    ROUND(AVG(GDP), 2) AS avg_gdp,
    ROUND(AVG(Schooling), 2) AS avg_schooling
FROM lifeexpectancy
WHERE Status = 'Developing'
GROUP BY Country
HAVING AVG(Life_expectancy) > 75
ORDER BY avg_life_expectancy DESC;


-- Các nước đang phát triển đầu tư vào giáo dục và y tế

WITH DevelopingAvg AS (
    SELECT 
		AVG(Life_expectancy) as avg_life_expectancy_developing,
        AVG(Schooling) AS avg_schooling_developing,
        AVG(GDP * (percentage_expenditure / 100)) AS avg_health_expenditure
    FROM lifeexpectancy
    WHERE Status = 'Developing'
)
SELECT 
	l.Country, 
    ROUND(AVG(l.Life_expectancy), 2) AS avg_life_expectancy,
    ROUND(d.avg_life_expectancy_developing, 2) AS avg_life_expectancy_developing,
    ROUND(AVG(l.Schooling), 2) AS avg_schooling,
    ROUND(d.avg_schooling_developing, 2) AS avg_schooling_developing,
    ROUND(AVG(l.GDP * (l.percentage_expenditure/100)), 2) AS avg_percentage_expenditure,
    ROUND(d.avg_health_expenditure, 2) AS avg_health_expenditure_developing
FROM lifeexpectancy l
CROSS JOIN DevelopingAvg d
WHERE l.Status = 'Developing'
GROUP BY l.Country, 
         d.avg_schooling_developing, 
         d.avg_health_expenditure
HAVING AVG(l.Life_expectancy) > 75
ORDER BY avg_life_expectancy DESC
LIMIT 5;

-- Tỷ lệ tự tử theo từng năm
SELECT 
  year,
  SUM(suicides_no) AS total_suicides,
  SUM(population) AS total_population
FROM suicide
WHERE year BETWEEN 2000 AND 2014
GROUP BY year
ORDER BY year;

-- Thống kê số người chết theo các nguyên nhân khác nhau theo từng năm
WITH life_stats AS (
  SELECT 
    year,
    SUM(infant_deaths) AS infant_deaths,
    ROUND(SUM(Adult_Mortality * population / 1000)) AS adult_deaths,
    ROUND(SUM(
      Adult_Mortality * population / 1000 + infant_deaths + 'under-five_deaths'
    )) AS total_estimated_deaths
  FROM lifeexpectancy
  WHERE population IS NOT NULL
  GROUP BY year
),
suicide_stats AS (
  SELECT 
    year,
    SUM(suicides_no) AS total_suicides,
    SUM(population) AS total_population
  FROM suicide
  WHERE year BETWEEN 2000 AND 2014
  GROUP BY year
)
SELECT 
  l.year,
  l.infant_deaths,
  l.adult_deaths,
  s.total_suicides,
  l.total_estimated_deaths,
  s.total_population
FROM life_stats l
JOIN suicide_stats s ON l.year = s.year
ORDER BY l.year;

-- Giới tính có tỉ lệ tự tử cao nhất theo từng độ tuổi
WITH cte AS (
SELECT sex, age, SUM(suicides_no) AS number_of_suicide,
ROW_NUMBER () OVER (PARTITION BY age ORDER BY SUM(suicides_no) DESC) AS rank_sui
FROM suicide
GROUP BY age, sex)
SELECT sex, age, number_of_suicide
FROM cte
WHERE rank_sui = 1
ORDER BY 
    CASE age
        WHEN '5-14 years' THEN 1
        WHEN '15-24 years' THEN 2
        WHEN '25-34 years' THEN 3
        WHEN '35-54 years' THEN 4
        WHEN '55-74 years' THEN 5
        WHEN '75+ years' THEN 6
        ELSE 7
    END;


-- Nhóm tuổi có tỉ lệ tự tử cao nhất theo giới tính
with cte as (
select sex, age, sum(suicides_no) as number_of_suicide,
row_number () over 
(partition by sex order by sum(suicides_no) desc) as rank_sui
from suicide
group by age, sex)
select sex, age, number_of_suicide
from cte
where rank_sui = 1;

-- Tương quan giữa GDP và tỷ lệ tự tử
SELECT 
    l.Country,
    l.GDP,
    ROUND(s.total_suicides / l.population * 100000, 2) AS suicides_per_100k
FROM life_2014 l
JOIN suicides_2014 s 
  ON l.country_year = s.country_year
WHERE l.GDP IS NOT NULL AND l.population > 0
ORDER BY suicides_per_100k DESC;

-- Tương quan giữa GDP và tỷ lệ tự tử
SELECT 
    l.Country,
    l.region,
    l.GDP,
    ROUND(s.total_suicides / l.population * 100000, 2) 
    AS suicides_per_100k
FROM life_2014 l
JOIN suicides_2014 s 
  ON l.country_year = s.country_year
WHERE l.GDP IS NOT NULL AND l.population > 0
ORDER BY suicides_per_100k DESC
LIMIT 10;

SELECT AVG(GDP) FROM life_2014;

Select Country, GDP from life_2014
order by GDP desc
limit 10;

SELECT * FROM lifeexpectancy.life_2014;


ALTER TABLE life_2014 ADD COLUMN GDP FLOAT;

UPDATE life_2014 l
JOIN lifeexpectancy le 
  ON l.country_year = le.country_year 
SET l.GDP = le.GDP;