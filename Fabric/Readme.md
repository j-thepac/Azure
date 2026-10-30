# Fabric
- PurView

## Learn By Doing : Fabric Practice 
PreReq: Create Fabric Account
1. Create account in Azure
2. Create a sample user in Azure > EntraID > Users
3. Once Created > Click on new User >Assigned role >Add assignments> Add Fabric Administrator
4. logout
5. Open  https://www.microsoft.com/en-us/microsoft-fabric/getting-started
6. Login with the new user created .
7. Select User Account profile > Free Fabric Trail > East US

Url : Open app.fabric.microsoft.com

### Activity 1: Build Medallion Architecture  
**Design** : 
Src > LakeHouse(Files) > Lakehouse(Delta) > Warehouse(SQL)

1. Open Fabric > NewWorspace > Select Fabric Trail >Enter "test" Save
2. Workspace > Predefined TaskFlow > Medallion
3. Perform:
	- Keep only 1 GetData
	- Remove Silver (Bronze can store both Silver and Bronze)
	- Remove ML Task 
4. Rename and add item: 
	1. Ingest 	> New Item > pipeline
	2. Bronze_Silver > New Item > LakeHouse
	3. Clean 	> New Item > Notebook
	4. Transform 	> New Item > Notebook
	5. Gold 	> New Item > Warehouse
	6. Visualize	> New Item > Semantic (add this later)
5. Ingest : 
	- Pipeline + CopyData
	- Source = https://github.com/j-thepac/Azure/raw/refs/heads/main/Fabric/GlobalSuperstore.xlsx
	- dest = Lakehouse and path  GlobalSuperstore/Timestamp/file.xlsx
	- Save and Run
6. Clean:
	- Notebooks pyspark
	- Add dataitems > DataCatalog> Lakehouse
	- Read xlsx as pandas(4 tabs) 
	- Fix column names
	- Add TS column
	- Write into Lakehouse as Pyspark Delta
7. Transform:
	- TSQL
	- Add dataitems > DataCatalog> Lakehouse
	- verify Data using inspect: Select * from Lakehouse.schema.Table
	- create schema GlobalSuperstore
	- ```  drop table if exists GlobalSuperstore.DimCustomer;
		create Table GlobalSuperstore.DimCustomer as
		select row_number() over (order by CustomerID) as CustKey,*,1 as Active
		from Lakehouse.GlobalSuperStore.Customer```
	- Wait for few min to reflect
	- Create Fact and Dim (code below)
		- DimCustomer
		- DimProduct:ProductKey, ProductID, ProductName, Category, Sub-Category
		- DimGeography:GeographyKey, City, State, Country, Region
		- FactSales: RowID, OrderID, OrderDateKey, ShipDateKey, CustomerKey, ProductKey, GeographyKey, Sales, Quantity, Discount, Profit, ShippingCost
8. Gold 
	- Open Warehouse > verify Data
9. Visualize
    - Add item > Semantic Model > One Lake Catalog >Select Warehouse > Save
	- Change Semantic model from Viewing >  Editing
	- Manage Relationship > New Relationship >1st Fact Table and 2nd Dim Table
	- repeat for all Dims 


``` 
Fact and Dim 
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

### Activity2 : Create PBI Dashboard
Pre- Req
- Install PBI desktop 
- Import semantic model in PBI

1. Setup Canvas
	- Set BG 
	- Set Header (TextBox > header)
2. Card Total Sales 
	- Visual >Callout>Value> font size
	- Visual > General > add Title
3. Bar graph Sales growth 
	- Visible x and Y axis 
	- ship_year = YEAR(FactOrders[ShipDate]) #DAX= Excel Formula
	- Wholenumber

### Activity 3: BikeShare 
- Design : Src > EventStream > A. Destination (Save Original)
  									 > B. Transformation > Filter > Destination
  
1. Fabric > NewWorspace > Select Fabric Trail > "Test" create
2. Add Item > Event Stream "Test" > Add sample >Bike > Add
3. Once add it is in Edit mode and User can preview the Data
4. Add ManageFields > select current_ts , BikeID, no_Bikes, No_Empty_docks
5. Add Filter > No_Bikes =0
6. Add Destination > EventHouse > Create New EventHouse , default DB and create new table
7. Add one more Destination (Eventhouse) direclty from source
8. save
9. Publich to Live Mode
10. Open EventHouse > DB> Table and notice Data increasing
11. To stop : Publish Eventstream > Deactivate

### Activity 4: CI/CD
#### CI
1. Goto Git > Create new Repo > Copy url
2. Create a main Branch 
  - Create a CodeSpace > checkout main branch > Modify Readme.md > Commit and push
  - Code space also available in top "+" button
3. Git >Settings > Developer Settings > Personal Access Token > Create and Copy 
4. Open Fabric > Settings > Admin > search "git" > Enable all
5. Workspace > WorkspaceSettings > Git > add name ,url and token >create >  connect 
6. Create new Notebook > Save
7. Workspace > Notice> Source Control has come up > Open > Commit File 

#### CD
1. Create 1 more workspace "Prod"
2. Workspaces > Deployment Pipelines > New pipeline > Keep only 2 ie., Dev > Prod > Create
3. Select each item in Pipeline and assign correct workspace
4. Click on Prod Pipeline Workspace > Select staged item and click on Deploy
----------------------------------
## Basics
1. Tenant is Company /Org
2. There is always 1 tenant
3. 1 tenant = 1 OneLake (N x lakehouses + N x Warehouses)
4. Company Can have multiple Projects = Workspaces
5. All Lakehouse and warehouse are created on same Onelake
6. Domain = Group of Workspaces
   
### Workspaces
1. Spark settings done at workspace
2. Install spark lib at workspace
3. Default Spark:
	- Always running
	- start immediately (if no customization is applied)
4. Custom Spark:
	- Setting : Workspace > Setting > Data Eng > Env > Set Default Setting and under drop down create New 
	- Takes normal time 3-4 mins to start
	- Set by Workspace Admin
	- Concurrency : Mulitple Notebooks /pipeline use same spark (Setting : Workspace > Setting > Data Eng > Concurrency)  
5. ShortCut Caching : Access and store data from external sources S3 , SAP  etc., 
   - Workspace > Settings > OneLake > Enable cache for shortcuts
   - Keep data only fro 24hour
   - Each file <= 1GB only
   
### Roles:
1. Fabric Admin (Tenant Level) - All access across all Domain (group of Workspaces) Eg: Create , delete domains etc., 
2. Domain Admin -
   	- Can View only 1 domain
   	- add Contibutors to his Domain
   	- Change settings of his domain
3. Workspace Admin -
	- Can View and Change only to his workspace 
   
## Create Account Key 
- Once resource is created 
- Azure >open service > Security > Access Key 

## OneLake 

### Issues with Data Lake 
- multiple Data Lake Exists across Teams 
- Data Duplication
- Blob to gen2 : While create under advanced enable "Enable hierarchical namespace"

**Intro**
- Built on Data Lake Gen2
- One Single for 1 Tenant /  Company  
- One Lake can be accessed from Windows directly like Onedrive and can view all items like Db , lakeshouse , notebooks etc., 
- python to access onelake from local system - https://learn.microsoft.com/en-us/fabric/onelake/onelake-access-python
    - Make sure az is installed 
    - Login with correct user
    - Retry few times as code will take some time to connect 

### LakeHouse = Datalake (Files) + Warehouse (Tables)
- Created on Onelake 
- Onelake = n x LakeHouse
- ShortCut:
	- Can have shortcut pointing to : Other Onelake , Gen2 , S3 , Dataverse etc.,
	- Goto LakeHouse > Files >Ck 3 dots > Shortcut
   	- Avoid Data Duplication
   	- Can be used in Spark 
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
- Can be saved to Onelake : Workspace>rt ck Semantic Model > OneLake Integration

### Triggers
### Monitoring

## CI CD
### CI / Git
What cannot be checked in
- Any Data
- File Eg: Env files 
- Schedule
- Lakehouse tables
- Warehouse schema only


------------------------------
## PBI
1. semantic Model created in Fabric cannot be edited in PBI
2. Measure = Aggregration ,  Column = WithColumn
3. PBI
   - PBI service : To share dashboard 
4. Connect : Excel , SQL Server , Create Table , Semantic Model / Lakehouse / Warehouse  , Dataverse
5. Fabric > Settings > Developer Settings > Enable PBI
6. DAX = Excel Formula Eg:YEAR(FactOrders[ShipDate])


### Views on the left side
  - report View : UI chnages
  - Table View : Data changes
  - Semantic View
### Visualizations (Charts) : 
- Card,Line,Bar,Slicer and clear button,Kpi,Guage ,Maps , New Page ,Matrix
- To change font : Visualization > Format icon > Values
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
- ship_year = YEAR(FactOrders[ShipDate])
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
### PowerQuery 
  - Before PBI
  - UI same as DataFlow Gen2
  - Cannot modify Semantic Model
  - Fix null , Datatypes, Column names , Dups
  - String manipulation
  - Date fix
  - Custom Column (based on condition)
  - Feature : Format , Extract , Date buttons
  - Create Custom Column
  - Merge Column
-----------------------

## Event Streams
1. Is a DAG
2. Consists of 3 Items
    -Source+EventStream
    -Trnsformation
    -Destination
3. Source :
    - Event Stream: Acts as a connection point
    - External - CDC , IOT , EventHub
    - Fabric Events - Workspace , Data
    - Custom - Kafka
    - Sample
4. Transformation: Manage fields, Aggregate, Expand(explode), Filter, Group by, Union
    - ManageFields : change column name ,type , new Col , datetime , String and Math operation
5. Destination:
    - EventHouse : KQL
    - Lakehouse (Off by Default) 
    - Stream : Into other stream
    - Activator: alert
3. Mode: 
    - Edit : Preview
    - Live : Ingest Date
4. Source >http > https://konkan-railway-api.vercel.app/api/v4/fetchTrains
5. Real TIme Dashoboard using Maps with Latitude and Longitude

### Activity: Custom Python
1. Fabric > NewWorspace > Select Fabric Trail > "Test" create
2. Workspace > EventStream "test" > Create >
3. Add Source > Custom > Add
4. Publish the workspace to Edit
5. Source > Event Hub > Copy SAS key Connection String Primary and name
   -  Use in Python code : https://drive.google.com/drive/folders/1eNBaUVqX0_POLYtleiWsKDt7AWth5OHN
   - ```#pip install azure-eventhub
        from azure.eventhub import EventHubProducerClient, EventData
		producer = EventHubProducerClient.from_connection_string(conn_str=CONNECTION_STR, eventhub_name=EVENTHUB_NAME)
		event_data_batch = producer.create_batch()
		while true:
     		event_data_batch.add(EventData(json.dumps({"a":1})))
        	producer.send_batch(event_data_batch)
     		time.sleep(3)
     ```
   - Run Code and see the result in event stream
   - Add Transform > Expand (explode rows) > Manage Fields(col  transformation) >GroupBY >Destination (EventHOuse)
### KQL : Kusto Query Language
1. | symbol passes the result of one operation to the next, forming a query pipeline.

```
table_name --show table

table_name 
|project c1 ,c2	-- select
|extend c3 = fn()
|take 100	-- pyspark rdd
|count


table_name
| where c != 30 and c2 == '1' and c3 contains "a"
| sort by Timestamp desc


table_name
| summarize new_col = count() by c -- group by c

.show_tables
.create table Tablename(id:int,name:string)
.ingest inline into table Tablename <| 1,a
.clear table Table name -- off one lake availablity
.drop materialized-view V
------------------
.create materialized-view with(backfill=true,effectiveDateTime=datetime(2025-02-01)) V on table table_name
{table_name
|count}
-----------------
.create function with f(id:int){
table_name
|where c=id}  --f(1)

-- practise window functions
-- 
