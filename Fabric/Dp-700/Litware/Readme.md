# DP-700 Case Study: Litware, Inc. – Microsoft Fabric

## 1. Case Study Overview

This case study describes Litware, Inc., a publishing company that wants to expand its Microsoft Fabric platform to support its existing sales analytics and new data requirements.

### Company Profile

Litware, Inc. is a publishing company that:
- Operates an online bookstore.
- Operates several retail bookstores worldwide.
- Manages an online advertising business for the authors it represents.

The company uses Microsoft Fabric for data engineering and analytics.

---

## 2. Existing Environment

### 2.1 Fabric Environment

- Litware has a Fabric workspace named `Workspace1`.
- High concurrency is enabled for `Workspace1`.
- The data engineering team uses Python for data processing.

### 2.2 Source Systems

Litware has the following existing source systems.

#### A. Retail Bookstores

- Retail bookstores send sales data at the end of each business day.
- Sales data is sent to a central Enterprise Resource Planning (ERP) system.

#### B. Online Bookstore

- The online bookstore continuously generates logs and sales data.
- The data is sent to the central ERP system.

#### C. Central ERP System

- Receives sales data from both retail and online bookstores.
- Sales data is exported from the ERP system as Parquet files.
- These files land in the `Files` folder of a Lakehouse.

#### D. Azure Blob Storage

- Litware stores book cover images in Azure Blob Storage.
- The image files are loaded into the Lakehouse `Files` folder.

### 2.3 Existing Data Processing Architecture

Litware implements a medallion architecture with three layers:

| Layer | Storage | Processing |
|---|---|---|
| Bronze | Lakehouse Delta tables | Notebooks |
| Silver | Lakehouse Delta tables | Notebooks |
| Gold | Fabric Warehouse | Notebooks / data processing |

Existing processing flow:

```text
Retail Bookstores ──┐
                    ├──> Central ERP
Online Bookstore ───┘
                          |
                          v
                    Parquet Files
                          |
                          v
                    Lakehouse Files
                          |
                          v
                       Bronze
                    Delta Tables
                          |
                          v
                       Silver
                    Delta Tables
                          |
                          v
                        Gold
                      Warehouse
```

**Important existing configuration:**
- Bronze and Silver are Delta tables in a Lakehouse.
- Gold is stored in a Fabric Warehouse.
- V-Order is disabled in the Gold Warehouse.

---

## 3. Existing Sales Data

### 3.1 Sales Data Ingestion

Sales data is captured using a **Dataflow Gen1** dataflow.

When the dataflow runs:
- It captures new sales data.
- It also captures historical sales data.

The dataflow captures the following fields:

| Field | Description |
|---|---|
| Sales Date | Date of the sale |
| Author | Author associated with the sale |
| Price | Price of the book |
| Units | Number of units sold |
| SKU | Stock Keeping Unit |

### 3.2 Sales Data Refresh Behaviour

| Requirement | Details |
|---|---|
| Source refresh frequency | Every six hours |
| First refresh | Midnight each day |
| Month-end processing | First calendar day of each month |
| Historical data | Data older than one month never changes |

### 3.3 Author Sales Data

A table named `AuthorSales` stores sales data relating to each author.

The table contains:

- `AuthorEmail`

Authors authenticate to a guest Fabric tenant using their email addresses.

This information is relevant to author-level data security.

---

## 4. Existing Security Groups

Litware has the following security groups:

| Security Group | Purpose |
|---|---|
| Sales | Sales team |
| Fabric Admins | Fabric administrators |
| Streaming Admins | Streaming administrators |

---

## 5. Existing Performance Issues

Litware has identified several performance and operational problems.

### 5.1 Warehouse Query Failures

- Business users execute ad-hoc queries against the Warehouse.
- Some reports take up to two hours to run.
- Some reports fail to load as expected.
- The data engineering team receives the following error:

```text
The SQL query failed while running.
```

**Requirement:**
- Debug the issue.
- Identify queries that cause more than one failure.

### 5.2 Increased Sales Activity

- New book releases often cause an increase in sales activity.
- Increased activity slows down the data ingestion process.

### 5.3 Outdated Sales Data

- The sales team reports that sales data was not up-to-date when they arrived at work in the morning during the previous month.

---

## 6. Planned Changes

Litware plans to introduce new data sources and capabilities.

### 6.1 Book Reviews

- Litware has signed a contract to receive book reviews.
- The review provider exposes the data through Amazon Simple Storage Service (Amazon S3) buckets.

### 6.2 SEO Data

- Litware plans to manage Search Engine Optimization (SEO) for its authors.
- SEO data will be streamed from a REST API.

---

## 7. Version Control Requirements

Litware plans to implement version control in Microsoft Fabric.

Requirements:

- Use GitHub integration.
- Follow the principle of least privilege.

---

## 8. Governance Requirements

To control data platform costs:

- Use only Microsoft Fabric services and items.
- Do not provision additional Azure resources.

**Important:** Existing source systems, such as Azure Blob Storage and Amazon S3, remain part of the environment. The restriction is against provisioning additional Azure resources.

---

## 9. Data Requirements

Litware has identified three new data requirements.

### 9.1 SEO Data – Near-Real-Time Processing

- SEO data is exposed through a REST API.
- Data must be processed in near-real-time (NRT).

### 9.2 Book Reviews – No Data Copy

- Book reviews are stored in Amazon S3.
- The reviews must be made available in the Lakehouse.
- A copy of the source data must not be created in the Lakehouse.

### 9.3 Book Cover Images – Event-Driven Processing

- Book cover images are stored in Azure Blob Storage.
- Images are loaded into the Lakehouse `Files` folder.
- When a new book cover image arrives in the `Files` folder, it must be processed as soon as possible.

---

## 10. Architecture Summary

### 10.1 Existing Architecture – Sales Data Platform

| Component | Responsibility |
|---|---|
| Retail bookstores | Send daily sales data |
| Online bookstore | Send continuous sales data and logs |
| Central ERP | Receives sales data |
| Dataflow Gen1 | Captures new and historical sales data |
| Lakehouse Files | Stores incoming ERP Parquet files |
| Bronze | Stores raw Delta data |
| Silver | Stores transformed Delta data |
| Gold Warehouse | Serves analytical data |
| AuthorSales | Stores sales data associated with authors |
| High concurrency | Enabled in Workspace1 |
| Warehouse Query Insights | Investigate query failures |

### 10.2 New Architecture – SEO Data

```text
SEO REST API
     |
     v
Eventstream
     |
     v
Eventhouse
     |
     v
KQL Queries
```

Requirement: Near-real-time processing of SEO data.

### 10.3 New Architecture – Book Reviews

```text
Amazon S3
    |
    v
OneLake Shortcut
    |
    v
Lakehouse Files
```

Requirement:
- Make book reviews available in the Lakehouse.
- Do not copy the source data.
- Use a shortcut to access the original S3 data.

### 10.4 New Architecture – Book Cover Images

```text
Azure Blob Storage
        |
        v
Lakehouse Files Folder
        |
        v
OneLake FileCreated Event
        |
        v
Fabric Activator
        |
        v
Fabric Pipeline
        |
        v
Python Notebook
        |
        v
Process Book Cover Image
```

Requirement: Start processing as soon as a new image arrives.

### 10.5 Version Control

```text
GitHub Repository
        |
        v
Fabric Git Integration
        |
        v
Workspace1
```

Requirement:
- Use GitHub integration.
- Apply least-privilege access.

---

## 11. Requirement-to-Solution Mapping

| Requirement | Relevant Fabric feature |
|---|---|
| Existing Bronze and Silver processing | Lakehouse + Notebooks |
| Existing Gold analytical storage | Fabric Warehouse |
| Near-real-time SEO processing | Eventstream + Eventhouse |
| Access Amazon S3 without copying data | OneLake Shortcut |
| Detect newly arrived Lakehouse files | OneLake FileCreated event |
| Trigger image processing | Fabric Activator |
| Orchestrate image processing | Fabric Pipeline |
| Process images using Python | Fabric Notebook |
| Investigate repeated Warehouse query failures | Warehouse Query Insights |
| Source control using GitHub | Fabric Git integration |
| Restrict access | Least-privilege permissions |
| Avoid provisioning additional Azure resources | Fabric-native services and items |

---

## 12. Important Exam Facts

| Fact | Exam significance |
|---|---|
| Workspace1 has high concurrency enabled | Existing workspace configuration |
| Data engineering team uses Python | Relevant to notebook processing |
| Retail sales arrive daily | Batch ingestion |
| Online sales arrive continuously | Continuous source data |
| ERP files are Parquet | File-based ingestion |
| Bronze and Silver use Delta | Lakehouse storage |
| Gold is a Warehouse | Analytical serving layer |
| V-Order is disabled | Existing Warehouse configuration |
| Dataflow Gen1 captures new and historical data | Existing ingestion process |
| Source refreshes every six hours | Refresh frequency |
| Data older than one month never changes | Historical data characteristic |
| Month-end processing runs on the first calendar day | Monthly processing requirement |
| AuthorSales contains AuthorEmail | Relevant to dynamic RLS |
| Authors use guest accounts | Cross-tenant authentication context |
| Warehouse reports fail after long execution | Performance troubleshooting |
| Need to find queries with multiple failures | Query diagnostics |
| New book releases increase sales activity | Ingestion performance issue |
| Sales data is outdated in the morning | Refresh scheduling issue |
| SEO comes from REST API | Near-real-time ingestion |
| Reviews come from Amazon S3 | Shortcut / no-copy access |
| Images arrive in Lakehouse Files | File event trigger |
| GitHub integration required | Source control |
| Least privilege required | Security design |
| No additional Azure resources | Governance and cost constraint |

---

## 13. Final Case Study Question

**Question:**

You need to create a workflow for the new book cover images.

Consider the following requirements:

- Book cover images are stored in Azure Blob Storage.
- The images are loaded into the Lakehouse `Files` folder.
- When a new image arrives, processing must start as soon as possible.

**Key requirement:** The workflow should react to the arrival of a new file rather than wait for a scheduled execution.