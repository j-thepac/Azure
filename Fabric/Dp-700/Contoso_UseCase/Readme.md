# Contoso – Microsoft Fabric Case Study

## 1. Company Overview

Contoso, Ltd. is an online retail company that wants to modernize its analytics platform by moving to Microsoft Fabric.

The company plans to begin using Fabric for **marketing analytics**.

## 2. IT Structure

The IT department has two teams:

### Data Engineers
- Perform data ingestion, transformation, and loading.
- Prefer Python or SQL for data transformations.

### Data Analysts
- Query data.
- Create semantic models and reports.
- Are familiar with Power Query and T-SQL.

## 3. Existing Environment

### 3.1 Fabric Environment

- Contoso has an **F64 capacity** named `Cap1`.
- All Fabric users are allowed to create items.
- Two existing workspaces:
  - `WorkspaceA`
  - `WorkspaceB`
- Both workspaces currently use **Pro license mode**.

### 3.2 Source Systems

#### POS1 – Point of Sale System

- Uses SQL Server running on an Azure Virtual Machine.
- SQL Server and Fabric are in the same Microsoft Entra tenant.
- The virtual machine is hosted on a private virtual network.
- Public access is blocked.
- Contains all sales transactions processed on the company's website.

#### MAR1 – Marketing SaaS Application

- MAR1 is a SaaS-based online marketing application.
- Contains **seven entities**.
- The entities contain:
  - Email open rates.
  - Email interaction rates.
  - Website interactions.
- Data can be exported through REST APIs.
- Each entity has a different API endpoint.

#### Historical MAR1 Data – Amazon S3

- Contoso has been using MAR1 for one year.
- Historical data from previous years is stored in an Amazon S3 bucket.
- Data is stored in Parquet format.
- There are **12 files**, each ranging from 300 MB to 900 MB.
- The files contain historical email interaction data.

### 3.3 Product Data

POS1 contains product information in three tables:

- `Products`
- `ProductCategories`
- `ProductSubcategories`

Relationships:

```text
Products
   |
   | ProductSubcategoryID
   v
ProductSubcategories
   |
   | ProductCategoryID
   v
ProductCategories
```

Products belong to subcategories, and subcategories belong to categories.

### 3.4 Azure Environment

Contoso has a Microsoft Entra tenant with the following mail-enabled security groups:

| Group | Members |
|---|---|
| DataAnalysts | Data analysts |
| DataEngineers | Data engineers |

Additional details:

- Contoso has an Azure subscription.
- An Azure DevOps organization already exists.
- A new Azure DevOps project has been created for Fabric-related repositories.

## 4. Existing User Problem

The VP of Marketing wants to analyze the effectiveness of different types of email content.

Current situation:
- Manually compiling and analyzing the data takes approximately **one week**.

Business goal:
- Reduce the analysis time to **less than one day** by using Microsoft Fabric.

Data engineering problem:
- The team has successfully exported data from MAR1.
- However, transient connectivity errors cause some data exports to fail.

## 5. Planned Changes

Contoso plans to create two lakehouses.

| Lakehouse | Purpose |
|---|---|
| Lakehouse1 | Store raw and cleansed data from source systems |
| Lakehouse2 | Serve data in a dimensional model for analytical queries |

Additional Fabric items will be created for data ingestion and transformation.

Contoso also plans to use **Azure Repos** for source control in Fabric.

## 6. Technical Requirements

### 6.1 Medallion Architecture

The lakehouses must follow the medallion architecture:

| Layer | Purpose |
|---|---|
| Bronze | Raw ingested data |
| Silver | Cleansed and transformed data |
| Gold | Business-ready analytical data |

MAR1 data requires extensive cleansing in the Silver layer, including:

- Deduplication.
- Handling missing values.
- Standardizing capitalization.

### 6.2 Pipeline Orchestration

- Each layer must be fully populated before the next layer starts.
- If any step fails, an email must be sent to the Data Engineers.
- Data imports must run simultaneously wherever possible.

### 6.3 Amazon S3 Requirements

The use of historical email data from Amazon S3 must:

- Minimize cross-cloud data egress costs.
- Prevent saving a copy of the raw data in the lakehouses.

### 6.4 Data Ingestion Requirements

Ingestion items must meet the following requirements:

1. Be source controlled alongside other workspace items.
2. Land ingested data in the Bronze layer of Lakehouse1.
3. Store ingested data in **Delta format**.
4. Perform no transformations before Bronze, except file-format changes.
5. Minimize development effort.
6. Use built-in source connections to import data.
7. Retry connections when transient connectivity errors occur.

### 6.5 Workspace Organization

| WorkspaceA – Data Engineering | WorkspaceB – Analytics |
|---|---|
| Lakehouses | Semantic models |
| Data pipelines | Reports |
| Notebooks | Dataflows |

### 6.6 Delta Table Maintenance

Once a week, remove old files that are no longer referenced by a Delta table log.

## 7. Data Transformation Requirements

### 7.1 Product Dimension

The Gold layer must contain a product dimension based on POS1 product data.

Requirements:

- `ProductID` values are unique.
- Include only active products.
- Active products have `IsActive = 1`.
- Exclude categories that are not assigned to any product.
- Exclude subcategories that are not assigned to any product.

### 7.2 Expected Product Relationships

```text
Products
   |
   | INNER JOIN
   v
ProductSubcategories
   |
   | INNER JOIN
   v
ProductCategories

Filter:
IsActive = 1
```

Only active products with valid subcategory and category relationships should appear in the Gold product dimension.

## 8. Data Security Requirements

### 8.1 Data Engineers

Must have:

- Read access to all lakehouses.
- Write access to all lakehouses.
- Access to underlying files.
- Permission to commit changes to source control in WorkspaceA.

### 8.2 Data Analysts

Must have:

- Read access only to Delta tables in the Gold layer.
- No access to Bronze data.
- No access to Silver data.


