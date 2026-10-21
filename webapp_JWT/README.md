# Azure

## Basic
1. EntraID 
  - Tenant / Company / Org
  - Create Users / Groups 
2. Resoure Group
  - Create this first before creating any service
  - All service is linked to this 
  - Deleteing this removes all services 
3. Commands 
 - az login
 - az <service> <list> eg:az group list , az webapp list


## Python App +JWT 
###  Part 1: App
1. Create Resource Graup: Azure  > Search  Resource groups → Create "mytime-rg"
2. Create Webapp : Search → App Services → Create → Web App
    - Subscription: Your subscription
    - Resource Group: mytime-rg
    - Name: mytime-api
    - Publish: Code 
    - Runtime stack: Python 3.12
    - Region: South India
    - Pricing:  F1 — Free
3. $zip -r mytime.zip app.py requirements.txt # flask + gunicorn
4. $az login
5. $az group list
6. $az webapp list
7. $az webapp config appsettings set --name mytime-api --resource-group mytime-rg --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true
  - $az webapp deploy --name mytime-api --resource-group mytime-rg --src-path mytime.zip --type zip
  - $az webapp config set --name mytime-api --resource-group mytime-rg --startup-file "gunicorn --bind=0.0.0.0:8000 app:app"
  - $az webapp restart --name mytime-api --resource-group mytime-rg
8. Find url : az webapp list /  Azure>webapp 

### Part 2: JWT Authentication

#### Step 1: Registration Entra ID

1. Azure Portal > Microsoft Entra ID > App registrations> Create `mytime-api`. and save.
2. Note down the **Application (client) ID** and **Directory (tenant) ID**.
3. Click Expose an API.
4. Set the Application ID URI to: api://<API_CLIENT_ID> and save
5. click on Add scope and set Scope name to  `Time.Read` eg:(<resouce>.Read)
6. select Admin and users
7. save

#### Step 2: Enable Authentication on App Service

1. Open App Service `mytime-api`>Authentication > Add identity provider
  - Choose **Microsoft**
  - App registration type : Pick an existing app registration in this directory
  - Additional checks: Allow requests from any application (Not recommended)
  - Require authentication
  - Set unauthenticated requests to return **HTTP 401 Unauthorized**.
  - Save the configuration.
2. Click on Edit: Add Allowed token audiences api://<API_CLIENT_ID> and <API_CLIENT_ID>
3. curl -i url #Expected: 401 Unauthorized
4. - az login --tenant <TENANT_ID> --scope api://<API_CLIENT_ID>/Time.Read
   - t=$(az account get-access-token --scope api://<API_CLIENT_ID>/Time.Read --query accessToken -o tsv)
   -  $curl -i -H "Authorization: Bearer $t" url # Expected: `200 OK
---

# Clean up
1. Open Azure Portal> App Service >click on "mytime-api"> Authentication > settings>Delete>Save
2. Check Api Url .Expected: `200 OK` without a token.
3. App registration > Delete obsolete
4. Azure Portal → Resource groups → delete the entire Resource Group.
----



