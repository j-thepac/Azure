# Azure + Terraform Setup

1. Login to Azure Portal as Admin.
2. Create Users and Group 
  - Entra ID → Users → New user → Create user `test`.
  - Entra ID → Groups → New group → Create group `test_group`.
  -`test_group` → Members → Add user `test`.
3. Create Resource Group
  - Resource Groups → Create `test_resource_group` → Region: `South India`.
  - RBAC (Role based Access control :Add user/group to a Role) 
    - `test_resource_group`> Access control (IAM)> Add role assignment>`SQL Server Contributor,SQL Security Manager`>Assign to `test_group` 
    - Scope: test_resource_group
4. Install Azure CLI on Ubuntu.
- Login to Azure CLI as `test` using `az login`.
- Check access :  $az account list and $az group list 
- Install Terraform using the official HashiCorp repository.
- Create Terraform project: `~/Programming/azure-terraform/sql`.


# Terraform / Azure Commands

```bash

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

terraform init
terraform validate # Validate Terraform syntax/configuration before applying
terraform plan # test,Password123
terraform apply # Apply the Terraform configuration
terraform destroy

# Terraform on error
terraform state list #Debug
terraform state show azurerm_mssql_server.sql
terraform state rm azurerm_resource_group.rg #remove from state
az sql server show --name test-sql-server-20261003 --resource-group test_resource_group -o table
```

## After Setup
1.Copy "azurerm_mssql_server.name" from main.tf 
  a. alternate :  Azure portal >goto Azure SQL> server created > Overview > Properties> Primary Endpoint  [copy]
2. Open DBeaver
3. New Connection
4. Search Azure SQL
5. Paste above host
6. Enter usn and password created 