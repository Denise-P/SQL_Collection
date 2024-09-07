
select * from layoffs;

# Hello today we're going to clean this dataset
# 1.Remove Duplicates
# 2. Standardize the Data
# 3. NULL values or blank values
# 4. Remove Any Columns 
create table layoffs_staging
like layoffs;

insert layoffs_staging
select * 
from layoffs;

select * from layoffs_staging;

select *,
row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;


with duplicate_cte as
(
select *,
row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging

)
select * 
from duplicate_cte
where row_num > 1;

create table `layoffs_staging2` (
`company` text,
`location` text,
`industry` text,
`total_laid_off` int default null,
`percentage_laid_off`  text,
`date` text,
`stage` text,
`country` text,
`funds_raised_millions` int default null,
`row_num` int
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,
row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;

# standardizing data

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;

select * 
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
where country like "United States%";

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select *
from layoffs_staging2
order by 1;

select `date`,
str_to_date(`date`, '%m/%d/%Y') # m & d must be lowercased for the library and Y must be captialized
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2 
modify column `date` date;

select * 
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

select distinct *
from layoffs_staging2
where industry is null 
or industry = '';

select * from layoffs_staging2
where company like "Bally%";

update layoffs_staging2
set industry = null
where industry = '';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null;

update layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null ) 
and t2.industry is not null;

# Remove columns and rows

select * from layoffs_staging2;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;