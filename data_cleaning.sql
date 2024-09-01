-- SQL Data Cleaing Project


SELECT *
FROM layoffs;

-- Creating a staging table to serve as a temporary workspace for data manipulation and analysis
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

/* 
# DATA CLEANING STEPS
1. Remove duplicates
2. Standardise the data
3. Treat Null or blank values
4. Remove irrelevant columns and rows
*/

SELECT *
FROM layoffs_staging;


-- 1. Remove duplicates

-- Checking for duplicates. The table has no unique row id so, window function will be employed.
SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
		`date`, stage, country, funds_raised_millions) AS row_num
	FROM
		layoffs_staging
) duplicates
WHERE
	row_num > 1;

-- Rewriting the query using CTE
WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions) AS row_num
FROM
	layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- creating another table that has extra row and then deleting the row where the row is equal to 2
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions) AS row_num
FROM
	layoffs_staging;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Deleting rows where 'row_num' is greater than 1
SET SQL_SAFE_UPDATES = 0;
DELETE
FROM layoffs_staging2
WHERE row_num > 1;



-- 2. Standardise the data

-- removing leading and trailing spaces from company column
SELECT
	company,
    TRIM(company)
FROM
	layoffs_staging2;

-- updating company column
UPDATE layoffs_staging2
SET company = TRIM(company);


-- the industry column has some null and blank rows. Cryto has multiple variations and needs to be standardised
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- There are 2 variations of 'United States': one with a period at the end and one without. 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- checking if it has been updated
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


-- Changing 'Date' Column Data Type

SELECT `date`
FROM layoffs_staging2;

-- using 'string to date' to update the field
SELECT
	`date`,
	STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- converting the data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- 3. Treat Null or blank values

SELECT *
FROM layoffs_staging2
WHERE 
	total_laid_off IS NULL
	AND percentage_laid_off IS NULL;

-- converting industry blank values to null values to make it easier to work with
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- checking to confirm the conversion
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
	OR industry = '';

-- ***
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE
	(t1.industry IS NULL OR t1.industry = '')
	AND t2.industry IS NOT NULL;


-- Updating table 1 to populate the null values where possible
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE
	t1.industry IS NULL
	AND t2.industry IS NOT NULL; 

-- Checking Airbnb
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


-- Deleting null values
DELETE
FROM layoffs_staging2
WHERE 
	total_laid_off IS NULL
	AND percentage_laid_off IS NULL;
    
-- Dropping row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;