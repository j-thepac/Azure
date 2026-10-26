# Fabric

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
- Vizualiation
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
### AirFlow 
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
1. One Lakehouse = Bronze (raw) and Silver (delta Tables)
2. Data :
    - Sample Data in Copy Activity
    - csv File in this repo 
        - Use Copy Acitivity 
        - http Format
        - Use Raw URL from Git

### Basic Medallion Framework : 
1. New Workspace
2. Select PreDefined TaskFlow  "Data analytics using SQL Endpoint"

#### TaskFlow
1.  Get Data (new Task)
    - add Add Task :   "Get Data" 
    - add item: Pipeline > Copy data 
    - source : Sample Data
    - dest : Raw Lakehouse 
    - Dest: File
    - Dest file Path = realestate and @concat(utcNow(),'/price_size_year.csv')
    - Save and run
2. Raw stores 
    - add item: Lakehouse 
    - name: bronze_silver
3. Process Data
    - add item: Notebook 
    - Attach Raw lakehouse
    - Read from csv files 
    - Add Ts , hashcolum
    -  write into delta table
    - Goto LakeHouse Table and Analyse > SQL endpoint>  check data 
4. Processed Data Store 
    - add item : Warehouse
    - Under 3 (Process Data)  
        - New Notebook >  TSQL script
        - Explorer :Add Warehouse and Lakehouse
        - create table gold.Taxi  as select * from Raw.dbo.Taxi
    - Create Views if needed
    - Open Warehouse > New Semantic Model 
5. Visualise:
    1. Go to workspace
    2. Visualize > Attach > select semantic Model from Step4
    3. Open Semantic Model > Convert Viewing to Editing 
    3. Build relationship using pk and FK
        1. link PK and Fk 
        2. check Datatypes , Column Names , Data Types
    4. Row Level Security
        1. Manager Roles > Create Role and condition
        2. Workspace > Rt Click on Semantic Model>Security>Add email
    5. Schdeule refresh
    6. Ontology :To build Context for AI 


