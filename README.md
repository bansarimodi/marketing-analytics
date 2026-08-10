Marketing Analytics Pipeline

An end-to-end marketing analytics project that brings togetheradvertisement performance, lead attribution, and sales funnel data tocreate business-ready reporting in Snowflake.

The solution follows a Medallion Architecture using Amazon S3,Snowflake, dbt, and Power BI. Daily source files are ingested from S3,transformed through Bronze, Silver, and Gold layers, and exposed throughreporting models for marketing and sales analysis.



Business Objective

Organizations collect marketing and sales data across multiple systems,making it difficult to understand the complete journey fromadvertisement interaction to sale.

This project builds a centralized Marketing Analytics Platform thatenables users to:

Measure advertisement performance.

Analyze lead generation across marketing platforms.

Understand First Source and Last Source attribution.

Track leads through the sales funnel.

Measure marketing and sales KPIs.

Support data-driven decisions through BI dashboards.

Source Datasets

The project uses three source datasets, each representing a differentpart of the marketing-to-sales journey.

Dataset                        Purpose                 Grain

HYROS_AD_ATTRIBUTION         Measures advertisement  One advertisement perperformance, including  reporting periodimpressions, clicks,leads, cost, revenue,ROI, and ROAS.

HYROS_LEADS                  Captures individual     One record perleads and their First   LEAD_IDSource and Last Sourcemarketing attribution.

How the Datasets Are Linked

HYROS_LEADS and MARKETING_INBOUND_CAMPAIGN have a direct lead-levelrelationship through:

HYROS_LEADS.LEAD_ID
        =
MARKETING_INBOUND_CAMPAIGN.LEAD_ID

This allows the project to connect how a lead was acquired withwhat happened to that lead in the sales process.

HYROS_AD_ATTRIBUTION provides advertisement-level performance data. Itdoes not contain LEAD_ID, so it is not directly joined to individuallead or sales records. Instead, it provides a complementaryadvertisement-performance view using attributes such as platform,advertisement, and reporting period.

In business terms:

Advertisement Performance → Lead Attribution → Sales Funnel → BusinessReporting

Architecture

Daily CSV Files
      │
      ▼
Amazon S3
      │
      ▼
Snowflake RAW / Bronze
      │
      ▼
dbt Silver
Cleaning • Standardization • Deduplication
      │
      ▼
dbt Gold
Dimensions • Facts • Business Metrics
      │
      ▼
Power BI
Dashboards & Business Insights

Technology Stack

Technology                          Purpose

Amazon S3                       Landing zone for daily source CSVfiles

Snowflake                       Cloud data warehouse for storageand analytics

dbt                             Data ingestion macros,transformations, testing, anddimensional modeling

Power BI                        Interactive dashboards and businessreporting

Data Processing

The pipeline is designed for daily incremental processing.

Daily CSV files are delivered to Amazon S3.

dbt macros load the source data into Snowflake.

Bronze models preserve ingested source data and audit metadata.

Silver models clean, standardize, deduplicate, and prepare thedatasets.

Gold models create dimensions and fact tables for reporting.

Power BI connects to the Gold layer to visualize business KPIs.

Key processing requirements include:

Incremental loading

Data type and date standardization

Null handling

Deduplication

Upserts for new and changed records

Source and audit metadata

Data quality validation

Gold Reporting Layer

The Gold layer provides business-ready dimensional models foradvertisement, lead attribution, and sales analysis.

Dimensions

dim_date

dim_platform

dim_ad

dim_campaign

Facts

fact_ad_performance

fact_lead_attribution

fact_sales_funnel

Dashboards

Advertisement Performance

Provides visibility into advertising activity and engagement.

KPIs and visuals:

Active Advertisements

Advertisement Leads

Advertisement Clicks

Advertisement Impressions

Top 10 Advertisements by Leads

Top 10 Advertisements by Clicks

Date-based filtering

Lead Attribution

Explains where leads originated and compares first-touch and last-touchattribution.

KPIs and visuals:

Total Leads

Daily Lead Trend

Leads by First-Touch Platform

Leads by Last-Touch Platform

Date-based filtering

Sales Funnel

Tracks lead progression through the sales process.

KPIs and visuals:

Triage Calls Booked

Triage Calls Taken

Triage No-Shows

Strategy Calls Scheduled

Strategy Calls Taken

Total Sales

Daily Sales Trend

Funnel Activity by Day

Date-based filtering

Marketing Attribution

The project focuses on two attribution perspectives:

First Source --- the first marketing touchpoint that introduceda lead to the business.

Last Source --- the final marketing touchpoint before the leadwas generated.

For example:

Facebook Advertisement
        ↓
Google Search
        ↓
Website Visit
        ↓
Lead Generated

First Source = Facebook
Last Source  = Google

This helps compare channels that create initial awareness with channelsthat influence the final lead conversion.

Data Quality and Validation

The project includes validation across the transformation and reportinglayers to confirm that:

Lead counts reconcile with source data.

Sales funnel metrics match the processed source records.

Advertisement metrics aggregate correctly by date and advertisement.

First Source and Last Source attribution totals reconcile with totalleads.

Gold fact tables match the expected Silver-layer records.

Dashboard values match Snowflake query results for the samereporting period.

Important Dataset Limitation

HYROS_AD_ATTRIBUTION is summarized at theadvertisement/reporting-period level and does not contain LEAD_ID.

Therefore, advertisement performance records cannot be directly joinedto individual leads or individual sales. The strongest directrelationship in the project is between HYROS_LEADS andMARKETING_INBOUND_CAMPAIGN through LEAD_ID.

Project Structure

marketing-analytics-pipeline/
│
├── dbt_marketing_analytics/
│   ├── macros/
│   ├── models/
│   │   ├── bronze/
│   │   ├── silver/
│   │   └── gold/
│   │       ├── dimensions/
│   │       └── facts/
│   ├── dbt_project.yml
│   └── packages.yml
│
├── docs/
│   └── marketing-data-journey.png
│
└── README.md

The exact repository structure may vary as the project evolves.

Running the dbt Project

From the dbt project directory:

dbt deps
dbt debug
dbt run
dbt test

To run a specific layer:

dbt run --select bronze
dbt run --select silver
dbt run --select gold

To rebuild an incremental model when required:

dbt run --full-refresh --select <model_name>

Business Value

The completed platform gives business users a consolidated view of themarketing and sales process. It helps teams understand:

Which advertisements generate engagement and leads.

Which platforms contribute to lead acquisition.

How First Source and Last Source attribution differ.

How leads progress through triage and strategy calls.

How many leads ultimately convert into sales.

Where marketing and sales performance can be improved.

