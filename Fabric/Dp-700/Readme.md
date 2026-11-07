## Framework : Always Medallion 
1. Bronze ( Source To Fabric)  
    1. Try Shortcut with Cache
    2. If above not useful : Use Mirror
    3. If above not useful : Pipeline + Copy (staging) into Lakehouse Files 
2. Silver ( Lakehouse DELTA tables ) : Bronze data to Delta Tables in Lakehouse using Notebook 
Note : Dataflow gen2 is only for small Datasets 
3. Gold (Warehouse) : Silver Data into WAREHOUSE Using TSQL

## Streaming : For Streaming data always use Event Stream
1. Use Transform Event(Event Processing) for Processing Data before Destination
2. Use EventHub for storing Data 
3. EventHub uses KQL for Queryin Data