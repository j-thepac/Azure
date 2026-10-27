# Fabric
- PurView
- Streaming
1. There is 1 Fabric account for a Tenent
2. Admin creates multiple workspaces for Project / Domains
3. All of these share 1 unified lake called One Lake

## Keywords
1. Capacity:  Resource Capacity
2. Experience : Services
3. Tenant : Org /Company 
4. Workspace : Project Folder
5. Tenant > Workspace > Experience (Data Engineering , PBI etc) > Item (Notebook)
6. Workspace:  Project

## Account
1. Create account in Azure
2. Create a sample user in Azure > EntraID > Users
3. Once Created > Click on new User >Assigned role >Add assignments> Add Fabric Administrator
4. logout
5. Open  https://www.microsoft.com/en-us/microsoft-fabric/getting-started
6. Login with the new user created .
7. Select User Account profile > Free Fabric Trail > East US

Url : Open app.fabric.microsoft.com

## Fabric Contents

### Workspace ( Project )
- Git 
- Networking
- Monitoring
- OneLake settings
### Account Key 
- Once resource is created 
- Azure >open service > Security > Access Key 

### Issues with Data Lake 
- multiple Data Lake Exists across Teams 
- Data Duplication
- Blob to gen2 : While create under advanced enable "Enable hierarchical namespace"

### One Lake 
- Built on Data Lake Gen2
- One Single for 1 Tenant /  Company  
- One Lake can be accessed from Windows directly like Onedrive
- python to access onelake from local system - https://learn.microsoft.com/en-us/fabric/onelake/onelake-access-python
    - Make sure az is installed 
    - Login with correct user
    - Retry few times as code will take some time to connect 

### LakeHouse = Datalake (Files) + Warehouse (Tables)
- Created on Onelake 
- Onelake = n x LakeHouse
- 2 types:
    - Files
        - Files and Folders
        - Structure , Unstructured and Semi Structured
        - abfs path (spark compatible )
        - Bronze
    - Tables: 
        - Delta Tables
        - Versioning 
        - Schema Evaluation
        - User run SQL on Tables
        - User can share SQL endpoints of Delta Tables
        - Silver

- File to table (delta) :
    - Any file (csv) can be converted to Delta Tables by "rtclick > load table.
    - Using Notebook 
        - Open Notebook > In Lakehouse Explorer, select Add Lakehouse
        - df=spark.read.format("csv").load("abfss://<path>/Files/<file>")
        - df.write.format("delta").mode("overwrite").options(path="abfss://<path>/Tables/<schema>/<table>/")
    c. Datafactory

- Shortcut in Files and Tables
    - For Lakehouse Folder and DB
    - To access file and Tables across multiple workspaces
    - Avoid Data Duplications
    - Collaboration
    - Single Source of truth
    - Types 
        - Internal :To work , Source and target needs to be located in same region
        - External: 
            - To work , Make sure to add permission to external source for Fabric to access
            - gen2 (same region)  , S3 , GCP , Salesforce
        - Cache : 
            - Create temporary Copy in Onelake
            - Improve perfromance
            - Profile > Workspace Settings > Onelake > Enable Cache

### Datapipeline
- Basic Feature :
    - parameters : Set before pipeline 
    - variables : Set at run time  
    - add run time dynamic content : to use parameters , variables , functions etc in the field
    - Concurrency

- Pipelines
    - Activities (Activites Tab > click on 3 dots) :
        - Copy Data : handle Faulty row and modify schema 
        - Delete : Delete Files
        - metadata (of files and folder) / Lookup(contents file/ table/sproc)
            1. One Item 
            2. Child Items (file size , count , date , schema )
                - Filter
                - Foreach/Until : should have childItems
                - set variable / Append variable : Intermediate value
                - if/switch :@and( equals(toLower(item().type),'file'), contains('_0123456789', substring(variables('name'), 0, 1)))
                - delete
        - Lookup : Fetch Data from Table / File /Sproce
        - Wait (Dummy)
        - parameters : Used to make pipeline Dynamic
    - Schedule: Pipeline > Schdeule
    - Monitor: 1) Pipleine Line > Run 2)Home > Monitor

### Dataflow Gen2 (Power Query)
- Power BI based transformations
- Query Settings: Edit , delete steps
- Transform : Home , Transform Tab
- Statistics : SUm , min , max etc. ,
- Add Column tab to add new column
- View > Diagram view to see the legacy Dataflow Diagram
- merge(join) : 
    - Fabric > WOrkspace > Data flow Gen2 
    - Home > new Query/Get Data > Blank Table  x2  # [(1,'a'),(2,'b')] ["id","name"]
    - Queries > rtclick > merge >Selet tables > Select PK 
    - Once merged > Click on merged columns drop down  and select all columns
    - Select destination
    - save 
    - once Save > Workspace > Select Dataflow > St clikc > schdeule
- Run : Home > refresh

### Spark 
- Start pool: Always on
- Custom Pool: Takes time to spin up
- notebookutils.help
- Environment (Install Custom library)
    - New Item > Environment > Configure and Save
    - Notebook > select Env or Open Workspace > Workspace Setting >DE >select Env

### Schedule : 
1. Using Pipleine 
2. Home>Rt click Item> Schedule

## Data Warehouse
- Delta Format
- Can use TSQL / spark / Dataflow Gen2
- Fabric > New Item > Warehouse
- new view /  Table /Stored Procedure (View+paramters)
- Visualization
-   create schema gold
    CREATE TABLE gold.E ( id INT ,Name VARCHAR(100));
    ALTER TABLE gold.E;
    ADD CONSTRAINT pk;
    PRIMARY KEY NONCLUSTERED (id) NOT ENFORCED;
- Inserting data Tables:
    - Pipeline : Dataflow , spark , Copy Activity
    - copy into
        - schema should already exist
        - copy into gold.T From "Onelake/ ABFS path" with(..)
    - create table as 
        - create table as gold.T as select * from lakehouse
        - CREATE TABLE gold.T as select * from openrowset(BULK 'adls.csv',FORMAT = 'CSV',PARSER_VERSION = '2.0',HEADER_ROW = TRUE)
- View 
    - Save business logic in the view
    - add Security
- Visual Query editor : Dataflow Gen2 UI transformations
- Notebook > select Tsql > open warehouse
- Lakehouse 1)File=Bronze

## Semantic Model
- Logical Representation of the Warehouse / Lakehouse 
- Warehouse/Lakehouse > Semantic Model > PBI 

### Triggers
### Monitoring
------------------------------
## PBI
### Connect : 
1. Excel
2. SQL Server
3. Direct Table
4. Semantic Model  / Lake House / Warehouse
5. Dataverse
### PowerQuery : Dataflow Gen2 tool in PBI
  - Before PBI
  - Fix null , Datatypes, Column names , Dups
  - String manipulation
  - Date fix
  - Custom Column (based on condition)
  - Feature : Format , Extract , Date buttons
  - Create Custom Column
  - Merge Column
### Views on the left side
  - report View : UI chnages
  - Table View : Data changes
### Charts : 
- Card,Line,Bar,Slicer and clear button,Kpi,Guage ,Maps , New Page ,Matrix
### Filter :
- Fabric > View > Filter  or Data > Select table > rtck > measure
- types: 1 chart , 1 Page ,all pages
- play with setting
- To remove change to select all
### Drill Down
### steps:
- based on information , find right columns
- Select Graph
- Apply columns
- Format graph
- Manage Relationships between tables
### DAX (Excel Formula)
- Examples: if statement , case , variables , functions
    ```Eg order_weekend_weekday = 
        var tmp_day = FORMAT(Orders[Order Date],"dddd")
        return if ( tmp_day in  {"Saturday", "Sunday"}, "Weekend", "Weekday")```
- Uses Column and Measure
    - Measure :  Aggregations (show in card)
        - Stored at Table /Tab level
        - Use Dax
        - Eg: Calculate(sum(T[0], Filter(T,T[c]>1000) #formula + filter
    - New Column = fx(table[col])
- Group :Column >Rtck > New Group
    - Show in chart (Eg: Pie)
- Append Query : Union
- Merge :Join
-----------------------
## Fabric Framework
1. Workspace > Predefined TaskFlow > Medallion
2. Perform:
	- Keep only 1 GetData
	- Remove Silver (Bronze can store both Data)
	- Remove ML Task 
3. Rename and add item: 
	1. Ingest 	> New Item > pipeline
	2. Bronze_Silver > New Item > LakeHouse
	3. Clean 	> New Item > Notebook
	4. Transform 	> New Item > Notebook
	5. Gold 	> New Item > Warehouse
	6. Visualize	> New Item > Semantic (add this later)
4. Ingest : 
	- Pipeline + CopyData
	- Source = https://github.com/j-thepac/Azure/raw/refs/heads/main/Fabric/GlobalSuperstore.xlsx
	- dest = Lakehouse and path  GlobalSuperstore/Timestamp/file.xlsx
	- Save and Run
5. Clean:
	- Notebooks pyspark
	- Add dataitems > DataCatalog> Lakehouse
	- Read xlsx as pandas(4 tabs) 
	- Fix column names
	- Add TS column
	- Write into Lakehouse as Pyspark Delta
6. Transform:
	- TSQL
	- Add dataitems > DataCatalog> Lakehouse
	- verify Data using inspect: Select * from Lakehouse.schema.Table
	- create schema GlobalSuperstore
	- ```  drop table if exists GlobalSuperstore.DimCustomer;
		create Table GlobalSuperstore.DimCustomer as
		select row_number() over (order by CustomerID) as CustKey,*,1 as Active
		from Lakehouse.GlobalSuperStore.Customer```

	- Wait for few min to reflect
	- Create Fact and Dim
		- DimCustomer
		- DimProduct:ProductKey, ProductID, ProductName, Category, Sub-Category
		- DimGeography:GeographyKey, City, State, Country, Region
		- DimDate: DateKey, FullDate, Day, Month, MonthName, Quarter, Year
		- FactSales: RowID, OrderID, OrderDateKey, ShipDateKey, CustomerKey, ProductKey, GeographyKey, Sales, Quantity, Discount, Profit, ShippingCost
7. Gold 
	- Open Warehouse > New Semantic Model
8. Visualize 
	- Workspace > Select Semanic Model and attach to Visualize Task
	- Chnage Semantic model to Editing
	- Manage Relationship > New Relationship >1st Fact Table and 2nd Dim Table
	- repeat for all Dims , but for date manually select column



``` Fact and Dim 
create schema GlobalSuperstore ;
drop table if exists GlobalSuperstore.DimCustomer ;
drop table if exists GlobalSuperstore.DimGeo;
drop table if exists GlobalSuperstore.DimProd;
drop table if exists GlobalSuperstore.FactOrders;
----
create Table GlobalSuperstore.DimCustomer as
select row_number() over (order by CustomerID) as CustKey,*,1 as Active
from Lakehouse.GlobalSuperStore.Customer;
----
create Table GlobalSuperstore.DimGeo as
SELECT 
    ROW_NUMBER() OVER (ORDER BY City, State, Country, Region) AS GeoKey,
    City, State, Country, Region,1 as Active
FROM (
    SELECT DISTINCT City, State, Country, Region
    FROM Lakehouse.GlobalSuperStore.Orders
) AS G;
----
create table GlobalSuperstore.DimProd as
select Row_Number() over (Order by ProductID, ProductName, Category, [Sub-Category]  ) as ProductKey,*, 1 as Active
from (
    select  distinct ProductID, ProductName, Category, [Sub-Category] 
    from Lakehouse.GlobalSuperStore.Orders
 ) T;
----
Create Table GlobalSuperstore.FactOrders as 
SELECT
    DimProd.ProductKey,
    DimGeo.GeoKey,
    DimCustomer.CustKey,
    O.Sales,
    O.Profit,
    O.Quantity,
    O.Discount,
    O.ShippingCost,
    O.OrderDate,
    O.ShipDate
FROM Lakehouse.GlobalSuperStore.Orders O
Left join GlobalSuperstore.DimProd on O.ProductID= DimProd.ProductID and O.ProductName=DimProd.ProductName and  O.Category=DimProd.Category and O.[Sub-Category]=DimProd.[Sub-Category] 
Left join GlobalSuperstore.DimGeo on O.City=DimGeo.City and O.State=DimGeo.State and O.Country=DimGeo.Country and O.Region=DimGeo.Region 
Left join GlobalSuperstore.DimCustomer on O.CustomerID=DimCustomer.CustomerID
```
	
