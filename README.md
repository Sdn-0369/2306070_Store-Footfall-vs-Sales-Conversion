# Store Footfall vs Sales Conversion

## Databricks & Snowflake Capstone Project

An end-to-end data engineering project that combines store footfall and billing data to analyze sales conversion at the store-hour level.

The project uses Databricks for data ingestion, transformation, validation, analytics, and pipeline orchestration, and Snowflake as the cloud data warehouse for SQL-based analysis.

---

## Project Details

- Name: Subham Debnath
- Batch: DATABRICKS And SNOWFLAKE 2026
- Project Domain: Data Engineering

---

## Problem Statement

Store footfall may increase without a proportional increase in sales. This project combines hourly footfall-counter data with billing-system data at a common store-date-hour grain to calculate sales conversion and identify periods where higher visitor traffic results in lower conversion.

The project focuses on building a reliable data pipeline that can clean, validate, transform, and analyze the two source datasets.

---

## Objectives

- Build an end-to-end data engineering pipeline using Databricks.
- Ingest store, footfall, and billing data.
- Implement Bronze, Silver, and Gold data layers.
- Preserve raw data while applying data-quality rules in the Silver layer.
- Handle invalid sensor readings and duplicate billing records.
- Reject invalid stores and bills outside trading hours.
- Create a store-hour level Gold dataset.
- Calculate sales conversion rate.
- Analyze conversion performance across hours and footfall levels.
- Export the Gold dataset and load it into Snowflake.
- Perform the required business analysis using Snowflake SQL.
- Automate the Databricks pipeline using a scheduled Job.

---

## Technology Stack

- Databricks
- PySpark
- Python
- Delta Lake
- Snowflake
- SQL
- GitHub
- CSV

---

## Architecture

```text
                    Raw Source Data
                          |
                          v
                 +------------------+
                 |    Databricks    |
                 | Data Generation  |
                 +------------------+
                          |
                          v
                 +------------------+
                 |  Bronze Layer    |
                 |   Raw Data       |
                 +------------------+
                          |
                          v
                 +------------------+
                 |  Silver Layer    |
                 | Clean & Validate |
                 +------------------+
                          |
                          v
                 +------------------+
                 |   Gold Layer     |
                 |   Store-Hour     |
                 +------------------+
                          |
                          v
                    CSV Export
                          |
                          v
                 +------------------+
                 | Snowflake Stage  |
                 +------------------+
                          |
                          v
                 +------------------+
                 | Snowflake Table  |
                 | GOLD_STORE_HOUR  |
                 +------------------+
                          |
                          v
                   SQL Analysis



---

## Author

**Subham Debnath**

---
