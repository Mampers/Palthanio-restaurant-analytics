# Palthanio-restaurant-analytics
End-to-end restaurant analytics solution using SQL Server data warehouse (Bronze/Silver/Gold architecture) and Power BI dashboards for financial, operational and KPI reporting.

## Overview

Palthanio Restaurant Analytics is a structured Business Intelligence solution built to support financial and operational decision-making across a multi-site restaurant environment.

The project demonstrates how raw operational data can be transformed into a governed, scalable reporting platform using SQL Server and Power BI.

## Business Goals

Monitor revenue, gross profit and profit after labour
Track labour cost % and waste impact
Analyse store-level performance
Improve financial transparency across locations
Replace manual Excel reporting with automated dashboards

## Architecture

The solution follows a Bronze → Silver → Gold data warehouse design:

Bronze: Raw data ingestion
Silver: Cleansed and validated data
Gold: Star schema model optimised for reporting

## Gold Layer Model

### Fact Tables

fact_orders
fact_store_daily_pnl
fact_labour_daily
fact_waste_daily

### Dimension Tables

dim_store
dim_date
dim_product
dim_employee

## Power BI Solution

The Power BI dashboard includes:

Executive KPI Overview
Revenue & Gross Profit Analysis
Labour & Waste Cost Tracking
Store Performance Comparisons
Dynamic filtering for daily and product-level insights

Key DAX measures include:

Profit After Labour
Labour Cost %
Waste Cost %
Time Intelligence (MoM / YoY)

## Tech Stack

SQL Server (T-SQL)
Data Warehouse Architecture
Star Schema Modelling
Power BI
DAX
Power Query

Repository Structure
/sql
/powerbi
/docs
/images

Author

Paul Mampilly

PL-300 Certified Power BI Developer
