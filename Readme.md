# Azure
1. Check existing Resources: Azure > All Resources 
2. Cost: Azure >search"Cost Management" >Reporting+Analysis > CostAnalysis > ResourceGroup

## User
- Azure → Entra ID → Users → New user → Create user `test`.
- Azure → Entra ID → Groups → New group → Create group `test_group`.
- open `test_group` → Members → Add user `test`

## Resouce Group 
- resounce Group = Users + Users Group + Role(PreCreated)
- Logical grouping 
- Deleting resouce groups deletes all resources
- Azure  >Resource Group > Create `test_resource_group` → Region: `South India`

## Access Management
### Managed Identity 
- Allows an Azure resource to authenticate to another Azure service without password.
- Eg: For Azure Function : Azure > Azure Function App > Select Function > Setting > Identity 
- Types : System-assigned , User-assigned
- **System-assigned**: 
    - When an identity belongs to just one resource.
    - Eg : Azure Function + Blob: 
        - Create AZ fn 
        - Az Fn > Settings > Identity> System Assigned > Turn On  
        - Create Blob and Container
        - After Creating > open > Access Control (IAM) > Add > Add role Assignment> Storage Bob COntrib > Managed Identity > Select above App
- **User-assigned**: 
    - When multiple resources need to use the same identity.
    - Eg : Azure Function + Blob: 
        - Azure > Managed Identities > Create "uaidentity"
        - Blob > Access Control (IAM) > Add > Add role Assignment>add Storage Bob Contrib >select Managed Identity > Add  "uaidentity"
        - Function App > Settings > Identity > User assigned > add > "uaidentity"

### Service Principle 
-  Applications should have their own identity to access other app 
- Eg Azure Fn + Blob :
    - Azure > Microsoft Entra ID > App registrations> New registration "testreg"
    - Click on Manage > Certificates and Secrets > New Secret > Copy Value
    - Blob Storage > IAM > Add Role Assignment > Storage Contributor > Next > Member> "testreg" > Save 
    - Azure Functions > Select Fn > Settings > Env Variables > Add TENANT_ID,CLIENT_ID,CLIENT_SECRET(copied value) , STORAGE_ACCOUNT






```

az login
az account list
az group list 
az provider list --query "[?registrationState=='Registered'].namespace" 
az sql server list 
az sql db list \
  --resource-group test_resource_group \
  --server test-sql-server-20261003 
az consumption usage list \
  --start-date 2026-10-01 \
  --end-date 2026-10-05 \
  --query "[?resourceGroup=='test_resource_group']" \
  -o table
az logout
```
