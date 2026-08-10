# Marketing Analytics Pipeline

An end-to-end marketing analytics project that brings together advertisement performance, lead attribution, and sales funnel data to create business-ready reporting in Snowflake.

The solution follows a **Medallion Architecture** using **Amazon S3, Snowflake, dbt, and Power BI**. Daily source files are ingested from S3, transformed through Bronze, Silver, and Gold layers, and exposed through reporting models for marketing and sales analysis.

## Business Objective

Organizations collect marketing and sales data across multiple systems, making it difficult to understand the complete journey from advertisement interaction to sale.

This project builds a centralized Marketing Analytics Platform that enables users to:

- Measure advertisement performance.
- Analyze lead generation across marketing platforms.
- Understand First Source and Last Source attribution.
- Track leads through the sales funnel.
- Measure marketing and sales KPIs.
- Support data-driven decisions through BI dashboards.