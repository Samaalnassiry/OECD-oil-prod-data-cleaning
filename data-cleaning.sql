#Our first query shows all the year values in the data set

SELECT DISTINCT TIME
 FROM `crude-oil-analysis.OECD_Crude_Oil_Production.product_by_country` ;

#The returned value is 62 years. Lets clean the table and remove any values below 2001

DELETE 
  FROM `crude-oil-analysis.OECD_Crude_Oil_Production.product_by_country`
  WHERE TIME < 2001;

#Next lets remove any countries that don't produce any oil all. To do this we will sum all the production values and create a new table, then delete all countries that have a value of 0 from the new table. Then we will create a final clean table by joining the new table. 

#CREATE TABLE `crude-oil-analysis.OECD_Crude_Oil_Production.prod_by_country_long` AS
(SELECT 
    _location_ as country,
    SUM(Value) as total_prod_value
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.product_by_country`
GROUP BY _LOCATION_);

--Deleting non-production countries from long data
DELETE 
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.prod_by_country_long`
WHERE total_prod_value = 0;

#CREATE TABLE `crude-oil-analysis.OECD_Crude_Oil_Production.clean_wide` AS
(SELECT *
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.product_by_country`
INNER JOIN `crude-oil-analysis.OECD_Crude_Oil_Production.prod_by_country_long`
ON _LOCATION_ = country
);

--Next we will validate all the distinct countries in the clean wide and the product by country long, they should match

SELECT DISTINCT _LOCATION_
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.clean_wide`;

SELECT DISTINCT country
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.prod_by_country_long`;


--Both values match at 98
---The final table will still include countries that had 0 production in a particular year!
SELECT * FROM `crude-oil-analysis.OECD_Crude_Oil_Production.clean_wide` 
WHERE value = 0;
-- There were 51 instances of non-production in the given time frame

SELECT DISTINCT _LOCATION_ FROM `crude-oil-analysis.OECD_Crude_Oil_Production.clean_wide` 
WHERE value = 0;
-- and they were limited to 8 countries

--Finally we will change the 3 letter ISO codes in the _Location_ column in the clean wide data to their full country names. A country code table has been uploaded seperately. This will help Tableau automatically detect countries in visiualization

UPDATE `crude-oil-analysis.OECD_Crude_Oil_Production.clean_wide`
SET _LOCATION_ = Countrys
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.country_codes`
WHERE _LOCATION_ = Code;

UPDATE `crude-oil-analysis.OECD_Crude_Oil_Production.prod_by_country_long`
SET country = Countrys
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.country_codes`
WHERE country = Code;

--Finally we will delete the following countries from the data, as they are regions

DELETE 
FROM `crude-oil-analysis.OECD_Crude_Oil_Production.clean_wide`
WHERE _LOCATION_ = 'G20'or
      _LOCATION_ = 'OEU'or
      _LOCATION_ = 'EU28' or
      _LOCATION_ = 'WLD' or
      _LOCATION_ = 'EU27_2020'
