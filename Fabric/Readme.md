# Fabric



## Account
1. Create account in Azure
2. Create a sample user in Azure > EntraID > Users
3. Once Created > Click on new User >Assigned role >Add assignments> Add Fabric Administrator
4. logout
5. Open  https://www.microsoft.com/en-us/microsoft-fabric/getting-started
6. Login with the new user created .
7. Select User Account profile > Free Fabric Trail > East US



Url : Open app.fabric.microsoft.com


## Fabric 
1. There is 1 Fabric account for a Tenent
2. Admin creates multiple workspaces for Project / Domains
3. All of these share 1 unified lake called One Lake

## Keywords
1. Capacity:  Resource Capacity
2. Experience : Services
3. Tenant : Org /Company 
4. Workspace : Project Folder
5. Tenant > Workspace > Experience (Data Engineering , PBI etc) > Item (Notebook)

## Contents

### Workspace ( Project )
- General Info
    -  Delete Workspace
- Memory Consumption
- Git 
- Networking
- Monitoring
- OneLake settings
- Data Engineering > Spark Configuration
- Data Factory 
### Account Key 
-Once resource is created 
- open service > Security > Access Key 


### Issues with Data Lake 
- multiple Data Lake Exists across Teams 
- Data Duplication
- Blob to gen2 : While create under advanced enable "Enable hierarchical namespace"

### One Lake 
- Built on Data Lake Gen2
- One Single for 1 Tenant /  Company  
- One Lake can be accessed from Windows directly like Onedrive
- python to access onelake from local system - https://learn.microsoft.com/en-us/fabric/onelake/onelake-access-python
    a. Make sure az is installed 
    b. Login with correct user
    c. Retry few times as code will take some time to connect 

### LakeHouse = Datalake (Files) + Warehouse (Tables)
- Created on Onelake 
- Any Number of LakeHouse in 1 Onelake
- 2 types:
    - Files
        - Files and Folders
        - Structure , Unstructured and Semi Structured
        - abfs path (spark compatible )
    - Tables: 
        - Delta Tables
        - Versioning 
        - Schema Evaluation
        - User run SQL on Tables
        - User can share SQL endpoints of Delta Tables

- File to table (delta) :
    a. Any file (csv) can be converted to Delta Tables but "rtclick > load table.
    b. Using Notebook 
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
- PBI
    - Semantic Model : PBI modeling
    - File > Table > Semantic Model > PBI Report
    - Views on the left side
      - report View : UI chnages
      - Table View : Data changes
    - Charts : Card,Line,Bar,Slicer and clear button,Kpi,Guage ,Maps , New Page ,Q&A chart
    - Filter :
        - 1 chart , 1 Page ,all pages
        - Top n
    - Drill  
    - steps:
      - based on information , find right columns
      - Select Graph
      - Apply columns
      - Format graph
    - Manage Relationships between tables
    - DAX
      - Formula
      - New Column = fx(table[col])
      - Google DAX formulas
      - Similar to excel formula on cells
      - if statement , case , variables , functions
        ```Eg order_weekend_weekday = 
         var tmp_day = FORMAT(Orders[Order Date],"dddd")
         return if ( tmp_day in  {"Saturday", "Sunday"}, "Weekend", "Weekday")```

### Datapipeline (Datafactory)
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

- Dataflow Gen2
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

- Triggers
- Monitoring
- Integration
- Spark 
    - Start pool: Always on
    - Custom Pool: Takes time to spin up
    - notebookutils.help
    - Environment (Install Custom library)
        - New Item > Environment > Configure and Save
        - Notebook > select Env or Open Workspace > Workspace Setting >DE >select Env
- Schedule : 
1.Using Pipleine 
2.Home>Rt click Item> Schedule

- AirFlow 

- Data Warehouse
    - Store Structure Data for analytics 
    - Fact (Quantitative) and Dim (Descriptive)
    - Fabric > New Item > Warehouse
    - Can query One Lake dbo from Warehouse
    - Result can be saved as new view / new Table
    - Vizualiation
    -   create schema gold
        CREATE TABLE gold.E ( id INT ,Name VARCHAR(100));
        ALTER TABLE gold.E
        ADD CONSTRAINT pk
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
    - Stored Procedure (View+paramters)
    - Visual Query editor : Dataflow Gen2 UI transformations
    - Notebook > select Tsql > open warehouse
