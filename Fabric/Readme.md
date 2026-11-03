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

Pre-Req:
Open Fabric > NewWorspace > Select Fabric Trail >Enter "test" Save
Workspace > Predefined TaskFlow > Medallion

Design :
Source_to_Bronze_Pipeline > Bronze_Silver_Storage_LH > Bronze_to_Silver_NP > Gold_WH > Visual_model

Stepes: 
1. Bronze
	- Store: 	Bronze_Silver_Storage_LH ( Files)  
	- Compute:	 Source_to_Bronze_Pipeline > Copy Data 
	- Source = https://github.com/j-thepac/Azure/raw/refs/heads/main/Fabric/GlobalSuperstore.xlsx
	- ingest in Timestamp subfolder
2. Silver 
	- Store: 	Bronze_Silver_Storage_LH (Tables)
	- Compute:	Bronze_to_Silver_NP = Spark nb + pandas (read xlsx 4 tabs ) 
	- Create Columns : Ts , Hash
	- Clean Column Name
	- New Delta Table for each Tab
	- path = "abfss://xxxx/Tables/Schema/Tablename
3. Gold: 
	- Store: 	Gold_WH 
	- Compute: 	Gold_WH ( No Notebook needed ) 
	- Open Warehouse , add above Lakehouse > New Query
	- Add is_active col for dim (scd 2)
	- Create Country (postalcode column has null) ,
	- Product dim (Product ID is repeated)from Orders 
	- Create Cust Dim from customer table
	- Create Fact Table with Surrogate Key and retain Business Columns
	- Verify : Count of Fact table shd not change 
```
create table GlobalSuperStore.DimCustomer as 
select ROW_NUMBER() over ( order by CustomerName asc) as CusKey,1 as is_active,*
from  (select DISTINCT CustomerID ,CustomerName , DateofBirth
     from Lakehouse.GlobalSuperStore.customer ) T	
```

4. SCD 2 
```
 declare @max_skey int
 set  @max_skey = select max(skey) from T
 insert into t 
select *,@max_skey+row_number() over ...
```


5. Star Schema
``` 
-- CREATE SCHEMA GlobalSuperStore;
drop table GlobalSuperStore.DimCustomer
create table GlobalSuperStore.DimCustomer as 
select ROW_NUMBER() over ( order by CustomerName asc) as CusKey,*,1 as is_active
from  (select DISTINCT CustomerID ,CustomerName , DateofBirth
     from Lakehouse_3_11.GlobalSuperStore.customer ) T


drop table GlobalSuperStore.DimCountry
create table GlobalSuperStore.DimCountry as 
select ROW_NUMBER() over (order by Country) as countryKey, *,1 as is_active
 from (
select DISTINCT  [State] , [Country] , Market , Region 
from Lakehouse_3_11.GlobalSuperStore.[order] ) T


drop table GlobalSuperStore.DimProduct
create table GlobalSuperStore.DimProduct as 
select ROW_NUMBER() over (order by ProductID ) as ProductKey, * ,1 as is_active
from (
select DISTINCT  [ProductID] , [ProductName] , [Category], [Sub-Category]
from Lakehouse_3_11.GlobalSuperStore.[order] ) T

drop table GlobalSuperStore.FactOrder
create table GlobalSuperStore.FactOrder as 
select 
prd.ProductKey
,ctry.countryKey
,cust.CusKey
,o.OrderID
,o.OrderDate
,o.ShipDate
,o.Sales
,o.Quantity
,o.Discount
,o.Profit
,o.ShippingCost
,o.OrderPriority
from Lakehouse_3_11.GlobalSuperStore.[order] o
left outer join GlobalSuperStore.DimCustomer cust on o.CustomerID=cust.CustomerID 
left outer join GlobalSuperStore.DimCountry ctry on o.[State]=ctry.[State] and o.[Country]=ctry.[Country] and o.Market=ctry.Market and o.Region=ctry.Region 
left outer join GlobalSuperStore.DimProduct prd on prd.[ProductID] = o.[ProductID] and  prd.[ProductName] = o.[ProductName]
```

### Activity2 : Create PBI Dashboard
Pre- Req
- Install PBI desktop
- login to Fabric
- Import semantic model in PBI
- open PBI > Get Date > Open Semantic Model
- Tab > Modelling > Make Changes to model ( to add new Column)

1. Setup Canvas
	- Set BG 
	- Set Title (TextBox > header)
2. Card Total Sales and Total profit
	- Visual >Callout>Value> font size
	- Visual > General > add Title
	- Make Total profit static (Format Edit interaction )
3. Bar graph Sales growth
	- Visible x and Y axis 
	- ship_year = YEAR(FactOrders[ShipDate]) **#DAX= Excel Formula**
	- Wholenumber
4.** Line and stacked Bar chart** :
	- To show profit as line and sales as stacked over years
	- Use format painter to copy formatting
5. Quarterwise sales in **Pie chart**
6. add **slicer** chart for Country :
   - Use slicer to see metrics for different countries
   - Multi Select
8. Add** Reset button** to reset slicer values
9. Add **KPI** to show target : TargetSales(Measure=5 mill) ,Total Sales , Year
   - TargetSales(Measure=5 mill) ,Total Sales , Year
   - Click on each year to see changes
10. How far from our target using **Guage** : Sales Vs Target (measure)


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
5. Warehouse shows schema to Git but not Lakehouse .
-------------------------------------------------------
## Basics
1. Tenant is Company /Org
2. There is always 1 tenant
3. 1 tenant = 1 OneLake (N x lakehouses + N x Warehouses)
4. Company Can have multiple Projects = Workspaces
5. All Lakehouse and warehouse are created on same Onelake
6. Domain = Group of Workspaces
7. Capacity Level = Compute level kept seperate for Workspace

## Roles:

1. Principle of least privilage( PolP ) = Min level of access
2. Global Admin : 
    - All access and all services and all tenants 
    - Create  all users /groups.
    - Create Fabric Admin 
2. Fabric Admin (Tenant Level) - 
    - Complete Fabric Access across all Domain 
    - Eg: Create , delete domains etc.,
3. Capacity Admin :
	- Controls Compute (spark) capacity for each workspace
 	- Cannot access other things
	- Fabric > Settings > Admin Portal > Capacity > 
4. Domain : Group of Workspaces
   	- Fabric > Settings > Admin Portal > Domain > Create Domain &  users
	- Domain Admin  
	   	- Can View only 1 domain
	   	- add Contibutors to his Domain
	   	- Change settings of his domain
    - Domain Contributor
    -  There is **NO** Domain Member and Viewer
5. Workspace Roles
   	- Workspace > Manage access > Add 
   	- Admin : Perform All operations
	- Member : Cannot Update , Delete Workspace , Add , remove people
	- Contributor ( Developer)  :
		- Cannot Update ,Delete Workspace and Add remove people
	 	- Cannot create and modify DB and Warehouse
  	 	- Can Read , Create , Write , Edit and run all items 
       	- Can Make connections 
 	- Viewer:
		- Read Data and Pipleines
		- Cannot execute 
		- Cannot make new connections
6. Item level Security:
	- Access to Entire Warehosue , Lakehouse , Notebooks
   	- Workspace > Select Item > ck 3 dots > Manage permissions > Add Users
   		- Notebook : 
            - Read 
            - Share (Reshare) :Permission to Share
            - Edit :
            - Run (Execute) 
   		- Lakehouse :
   	 		- Empty Permission : For give Row, Column ,Table level access
   	     	- Read SQL : Query Tables and See files
   	      	- Read all Apache Spark : 
                - To create ShortCut 
                - Read using Spark Nb , Read raw Files , Read Event 
   	      	- Build Report : 
                - Access to connect to semantic using PBI 
                - but no table level access
   	    - Warehouse:
   	    	- Empty Permission : For Row , Column , Table level access
   	    	- Read all data using SQL
   	       	- Read all Onelake data : All SQL + Saprk
   	       	- Monitor Queries : Monitor Warehouse
   	       	- Audit : Audit logs
   	       	- Share : Share granted permission with others 

7. Data Level Security: Individual Data in Lakehosue and Warehouse
    - Role Based Access (RBAC) :
        - Lakehouse >Top Onelake Security > Create Role - Read / ReadWrite
        - Select Data : File and Tables 
        - add Members 
    - SQL Access 
        - User needs to already have access to Warehouse / Lakehouse 
        - Lakehouse Tables , Warehouse
        - GRANT SELECT (row , column and Table  ) , REVOKE, DENY

8. Masking :
    - Underlying data is masked but not altered
    - But data can be guessed using between and like operators . 

    - ```create table T (nm varchar(10) masked with (function='fx') NULL)```
    - ``` Alter Table T add masked with (function='fx');```
    -  Alter Table T add masked with (function='partial(4,"X",0)'); -- 555-XXXX-XXXX
    - Types : 
        - default() 
        - email() 
        - random(start,end) --used for numbers
        -  partial(prefix,padding,suffix) 
   
## Data Governance  : 
1. Labelling data
2. Types : Endorsement , Tagging , 
3. Endorsement :
   - Admin : Admin Portal > Search for " Certification" > Enable 
   - Any Item
   - User :  Item > 3 dots > Settings > Endorsement
   - Types :
        - None
        - Promoted : Any one with write permission can apply this label
        - Certified :
   		    - Only selected users by Fabric Admin can apply this .
            - Item appears across all workspaces but data not accesiible yet
        - Master Data :
            - Only selected users by Fabric Admin can apply this .
            - Show data is single source of truth
4. Tagging :
   - Admin : Admin Portal > Tags
   - Only Fabric Admin can create Tags
   - User :  Item > 3 dots > Settings > Tags
   - Used for Filtering items
   - Any number of tags can be applied to same item 
5. Item Sensitivity Label :
   - Created in Fabric Purview , once created goto Admin Portal > search for "Sensitivity"
   - Fabric Admin enables in Admin Portal
6. Workspace Lineage :
   - Shows Data flow
   - Workspace:  Workspace > at the top Ck on Lineage View
   - Item level: Item Lineage > Item > Rt Ck > Lineage View
   

 


## Create Account Key 
- Once resource is created 
- Azure >open service > Security > Access Key 
--------------------------------------------------------------------------------------
## OneLake 
1. Lakehouse
2. Warehouse
3. Eventhouse
   
### Issues with Data Lake 
- multiple Data Lake Exists across Teams 
- Data Duplication
- Blob to gen2 : While create under advanced enable "Enable hierarchical namespace"

**Intro**
- Built on Data Lake Gen2
- 1 One Lake for 1 Tenant /  Company  
- One Lake can be accessed from Windows directly like Onedrive and can view all items like Db , lakeshouse , notebooks etc., 
- python to access onelake from local system - https://learn.microsoft.com/en-us/fabric/onelake/onelake-access-python
    - Make sure az is installed 
    - Login with correct user
    - Retry few times as code will take some time to connect 

### LakeHouse = Datalake (Files) + Warehouse (Tables)
- Created on Onelake 
- Onelake = n x LakeHouse
- Shortcut in Files and Tables
    - For Lakehouse Folder and DB
    - Avoid Data Duplications
    - Collaboration
    - Single Source of truth
    - ShortCut Types 
        - Internal :
            - To work , Source and target needs to be located in same region
        	- Can have shortcut pointing to : Other Onelake , Gen2 , S3 , Dataverse etc.,
	        - Goto LakeHouse > Files >Ck 3 dots > Shortcut
        	- Avoid Data Duplication
   	        - Can be used in Spark 
        - External: 
            -  Access and store data from external sources S3 , SAP  etc., 
            - Workspace > Settings > OneLake > Enable cache for shortcuts
            - Keep data only fro 24hour
            - Each file <= 1GB only
            - Create temporary Copy in Onelake
            - Improve perfromance
            - Profile > Workspace Settings > Onelake > Enable Cache

- Types:
    - Files ( Bronze ):
        - Files and Folders
        - Structure , Unstructured and Semi Structured
        - abfs path (spark compatible )
        - Bronze
    - Tables (Silver) :
        - Delta Tables
        - Versioning 
        - Schema Evaluation
        - User run SQL on Tables
        - User can share SQL endpoints of Delta Tables
        - Vorder : Increase read speed but decrease write speed
          - spark.conf.set("spark.sql.parquet.vorder.enabled", true)
          - ddf.options("parquet.vorder.default":"true")
          - %%sql  SET spark.sql.parquet.vorder.enabled=TRUE
        - table > 3 dots > maintenance 1)optimize size and Vorder 2) Vaccum +days 3) ddf.delete() will do softdelete

- File to table (delta) : Any file (csv) can be converted to Delta Tables by "rtclick > load table.
- Using Notebook 
    - Open Notebook > In Lakehouse Explorer, select Add Lakehouse
    - df=spark.read.format("csv").load("abfss://<path>/Files/<file>")
    - df.write.format("delta").mode("overwrite").options(path="abfss://<path>/Tables/<schema>/<table>/")

### Data Warehouse
- Delta Format but not exposed to user
- Can use TSQL / spark / Dataflow Gen2
- Fabric > New Item > Warehouse
- TYpes : 
    - new view 
    - Table 
    - Stored Procedure (View+paramters)

- Notebook > select Tsql > open warehouse
   ``` 
   create schema gold;
   CREATE TABLE gold.E ( id INT ,Name VARCHAR(100)); -- cannot create primary key on table creation
    ALTER TABLE gold.E ADD CONSTRAINT pk
    PRIMARY KEY NONCLUSTERED (id) NOT ENFORCED;```

- Inserting data Tables:
    - Pipeline : Dataflow , spark , Copy Activity
    - copy into
 ```
copy into gold.T From "Onelake/ ABFS path" with(..)

----create table as gold.T as select * from lakehouse
-----CREATE TABLE gold.T as select * from openrowset(BULK 'adls.csv',FORMAT = 'CSV',PARSER_VERSION = '2.0',HEADER_ROW = TRUE)
```
- View :  Save business logic and add Security
- Visual Query editor : Dataflow Gen2 UI transformations

### EventHouses
- KQL
- TimeSeries Data
- Real Time analysis , Geo Spatial 
--------------------------------------------------------------------------------------
## Orchestration : 
1. Pipeline
2. Spark
3. Dataflow
4. TSQL

### Pipeline : 
- Orchestrate all items in Workspace
-  Features :
    - parameters : Set before pipeline 
    - variables : Set at run time  
    - add run time dynamic content : to use parameters , variables , functions etc in the field
    - Concurrency
  	- Workflow > New Item >Pipeline
  	- Types :
  		- Move and Transform :
    		- Copy , Delete Data , Invoke SSIS
      		- Dataflow ,Spark Job Definition , Notebook , Script SQL, Stored Proecudre, KQL ,
  	   	- Metadata : Lookup and Get Metadata
  	   	- Control flow:  Set Variable , Append Variable ,If , Switch , Filter , Wait , Foreach, Until , Fail
  	   	- Orchestrate : Invoke Pipeline , Web , Webhook , Semantic model refresh , Azure Databricks , Functions , HD insight , Batch (cmd prompt), Refresh SQL
  	   	- Notification : Teams , Office Email , Outlook
  	   	- Lakehouse : Lakehouse Maintenence (run vaccum ) , Refresh Materialized view 
    - Activities (Activites Tab > click on 3 dots) :
        - Copy Data : Can handle Faulty row and also modify schema 
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
        - Sparkjob , Noteboo k , Script ,Stored Procedure , KQL , Inoke Pipeline , Semantic model Refresh 
    - Schedule: Pipeline > Schdeule
    - Monitor: 1) Pipleine Line > Run 2)Home > Monitor

### Dataflow Gen2 (Power Query)
- Power BI based transformations
- Query Settings: Edit , delete steps
- Transform : Home , Transform Tab
- Statistics : Sum , min , max etc. ,
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
- Spark Settings :
    -  Spark settings done at workspace
    - Workspace Settings > DE > Spark Settings > Env > Set Default env On > Create new Env 
    - Default Spark:
        - Always running
        - start immediately (if no customization is applied)
    - Custom Spark:
        - Takes normal time 3-4 mins to start
        - Set by Workspace Admin
    - Concurrency Setting: Multiple Notebooks /pipeline use same spark (Setting : Workspace > Setting > Data Eng > Concurrency) 
- notebookutils.help
- Environment (Install Custom library)
    - New Item > Environment > Configure and Save
    - Notebook > select Env or Open Workspace > Workspace Setting >DE >select Env
- Can also parallel notebooks in same session .
  ```from notebookutils import notebook 
  notebook.runmultiple(['n1','n2'])```
- ```%%sql
  create table T(id Int) -- create table in lakehouse 
  ```
- ``` deltatable.createOrReplace(spark).tableName("T").addColumns(schema).execute() #create table and scheam```


### Schedule : 
1. Workspace > select item > click on 3 dots  >  Schedule triggers
2. There is also Event Based Triggers (Real Time Hub)
3. PBI to detect semantic model changes: Semantic > 3 dots > settings > Refresh

## Monitoring
1. Monitoring Hub :  Workspace > Monitor
   - Item Level
   - Spark NB > Spark UI 
3. Capacity Metric App :
   - Capacity Consumption at workspace
   - Install Capacity Metric app (app store )
   - App > Open Compute Tab
   - Parts :
   	- Throttling (reject because capacity overloaded)
   	- Overages : Consume more capacity  
   	- System Events(Background events affecting capcity
4. Event Streaming > Runtime Logs
   - Types of Logs 
	   - Command Logs
	   - Data Operation Logs
	   - Ingestion results logs
	   - Metrics
	   - Query Logs 
6. Warehouse 
	- Warehouse > Editor > Monitor
	- Vorder :
 		- Makes read fast but write slow (Useful for OLAP)
     	- On by Default .To off -- ALter database current set voder =off;
        - Enabled at Workspace level
          
## Semantic Model
- Logical Representation of the Warehouse / Lakehouse 
- Warehouse/Lakehouse > Semantic Model > PBI
- Can be saved to Onelake : Workspace>rt ck Semantic Model > OneLake Integration
- Refresh : workspace > select Semantic Model > 3 dots > Settings > Refresh
- Monitored in Monitor Hub 

## CI CD

What cannot be checked in
- Any Data
- File Eg: Env files 
- Schedule
- Lakehouse tables
- Warehouse schema can be checked in

------------------------------
## PBI
1. semantic Model created in Fabric cannot be edited in PBI
2. Measure = Aggregration ,  Column = WithColumn
3. PBI service needed to share dashboard 
4. Connect : Excel , SQL Server , Create empty Table , Semantic Model / Lakehouse / Warehouse  , Dataverse
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
    -Transformation
    -Destination
3. Source + Event Stream(Acts as a connection point)
    - External - CDC , IOT , EventHub
    - Fabric Events - Workspace , Data
    - Custom - Kafka
    - Sample
4. Transformation: Manage fields, Expand(explode), Filter, Aggregate,Group by, Union
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
6. Optimization KQL :
   - filter first eg :```t
     					|where Name has "azure"```
   - use less columns
   - Use 'has' instead of 'contains'(slower) . has_cs(better) case sensitive
   
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
```
## Others
1. Mirror
   - Workspace > New Item > Search "mirror"
   - Make replicate of Datasources : Add Db , SAP , Catalog  , etc., 
   - To make 
