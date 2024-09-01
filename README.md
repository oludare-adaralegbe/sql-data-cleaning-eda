
# SQL Data Cleaning Project

## Overview

This repository contains SQL code and a csv file from a data cleaning project. The primary objective of this project is to prepare a raw dataset for further analysis by handling common data quality issues.

## Data Cleaning Steps

**Remove Duplicates:**

-   Identified and removed duplicate rows to improve data accuracy and avoid skewed analysis.
-   Used DISTINCT and ROW_NUMBER() to identify and remove duplicates.

**Standardise the Data:**

-   Converted 'date' field from 'text' to 'date' using STR_TO_DATE
-   Ensured data uniformity by standardising values using TRIM

**Treat Null or Blank Values:**

-   Converted blank values to null values to make it easier to work with
-   Removed rows with null values.

**Remove Irrelevant Columns and Rows:**

-   Removed the 'row-num' column created using the ROW_NUMBER() window function.

**Database System**

MySQL
