# Road Safety Data Warehouse & Accident Analysis

## Overview

This project builds an end-to-end **analytics pipeline** to analyze UK road accident data. The goal is to transform raw accident datasets into a structured **dimensional data warehouse** and extract insights about accident patterns, severity, and risk factors.

The pipeline integrates **AWS S3 for storage**, **Snowflake for data warehousing**, and **SQL analytics** to answer key road safety questions.

Key objectives:

* Build a scalable **cloud data pipeline**
* Implement **Bronze → Silver → Gold architecture**
* Design a **dimensional star schema**
* Perform analytical queries to uncover **road safety insights**

---

# Architecture Overview

The project follows a layered **Medallion Architecture**.


```text
Amazon S3 (Raw CSV Files)
        ↓
Snowflake External Stage
        ↓
Bronze Layer (Raw Tables)
        ↓
Silver Layer (Cleaned Tables)
        ↓
Gold Layer (Star Schema)
        ↓
Analytics Queries
```

---

# Tech Stack

| Tool                    | Purpose                         |
| ----------------------- | ------------------------------- |
| **Amazon S3**           | Raw data storage                |
| **Snowflake**           | Cloud data warehouse            |
| **SQL**                 | Data transformation & analytics |            |
| **Power BI**            | Data modelling                  |


---

# Data Pipeline

## 1. Data Storage – Amazon S3

Raw datasets are stored in an **Amazon S3 bucket**, which acts as the project's data lake.

Files stored in S3:

```
collisions.csv
vehicles.csv
casualties.csv
```

Snowflake connects to the S3 bucket using **external stages** to ingest data into the warehouse.

---

# Bronze Layer – Raw Data

The Bronze layer stores raw ingested data from S3 with minimal transformation.

Tables:

```
bronze.raw_collisions
bronze.raw_vehicles
bronze.raw_casualties
```

Purpose:

* Preserve source data
* Maintain traceability
* Serve as staging for transformations

---

# Silver Layer – Data Cleaning & Standardization

The Silver layer prepares the raw data for analytical use.

Key transformations include:

* Mapping coded values to readable descriptions
* Handling missing or unknown values
* Standardizing column names and types
* Preparing fields for dimensional modeling

Clean tables:

```
silver.collisions_clean
silver.vehicles_clean
silver.casualties_clean
```

Example transformation:

| Code | Description |
| ---- | ----------- |
| 1    | Fatal       |
| 2    | Serious     |
| 3    | Slight      |

---

# Gold Layer – Dimensional Data Warehouse

The Gold layer implements a **star schema optimized for analytics**.

## Fact Tables

| Table               | Grain                              |
| ------------------- | ---------------------------------- |
| **fact_collisions** | One row per accident               |
| **fact_vehicles**   | One row per vehicle in an accident |
| **fact_casualties** | One row per casualty               |

## Dimension Tables

* dim_date
* dim_weather
* dim_road
* dim_severity
* dim_vehicle
* dim_driver
* dim_casualty

---

# Data Model
<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/1f38ecae-37e5-40da-88f9-a436e6f79aba" />


# Key Insights

**Q: Which weather conditions are deadliest?**
A: High winds + rain = 2.78% fatal rate (2x worse than normal). Wind alone is the worst weather risk.

**Q: Are rural or urban areas more dangerous?**
A: Rural 2.9x deadlier (2.50% vs 0.85%). Higher speeds and slower emergency response.

**Q: Which age groups are highest risk?**
A: Drivers 75+ at 2.27% fatal rate. Young drivers 16-20 also risky at 1.57%. Ages 46-55 safest at 1.02%.

**Q: How do gender differences impact outcomes?**
A: Male casualties 2x more likely to die (1.53% vs 0.74%). Men take more risks.

**Q: Which road users face exceptional risk?**
A: Motorcyclists 5-6% fatal rate (4x worse than cars). Elderly pedestrians 6.25% fatal rate.

**Q: What's the seasonal pattern?**
A: Summer worst at 1.57% (+38% more deaths than autumn).

**Q: Do weekends increase risk?**
A: Yes, 70% higher. Sunday 1.85%, Wednesday 1.08%.

**Q: How do road surfaces affect severity?**
A: Flooded roads 4.1% fatal. Wet/icy roads ~1.5% fatal (2x worse than dry roads).

---
---

## Recommendations

1. **High-Wind Safety Protocol** → Dynamic speed alerts, vehicle restrictions
2. **Elderly Driver Testing** → Cognitive/vision assessments for 70+
3. **Rural Infrastructure** → Emergency response, barriers, enforcement
4. **Motorcyclist Protection** → Gear mandates, training, road marking
6. **Young Driver Education** → Scenario-based training, graduated licensing

---

# Future Improvements

* Automate ingestion using **Snowpipe**
* Add **Power BI dashboards**
* Implement **geospatial accident analysis**
* Add **data quality monitoring**

