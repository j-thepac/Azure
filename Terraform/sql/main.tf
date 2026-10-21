#make sure to login as $az login
# user : test@jthepacgmail.onmicrosoft.com
# roles needed : SQL Security Manager , SQL Server Contributor

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = "409c82a5-bbbb-4516-93db-5cd3c7eba263"
  resource_provider_registrations = "none"
}

provider "azuread" {}

# public_network_access_enabled = true  need to VNet/private access
#----------------------------------------
resource "azurerm_mssql_server" "sql" {
  name                          = "test-sql-server-20261003" #globally unique
  resource_group_name           = "test_resource_group"
  location                      = "South India"
  version                       = "12.0"
  administrator_login           = "test"
  administrator_login_password  = "Password123"
  public_network_access_enabled = true
}

resource "azurerm_mssql_firewall_rule" "public" {
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_mssql_database" "db" {
  name        = "test_db"
  server_id   = azurerm_mssql_server.sql.id
  sku_name    = "Basic"
  sample_name = "AdventureWorksLT"
}

data "azuread_user" "user" {
  user_principal_name = "test@jthepacgmail.onmicrosoft.com"
}

resource "azurerm_role_assignment" "sql_roles" {
  for_each             = toset(["SQL Security Manager", "SQL Server Contributor"])
  scope                = azurerm_mssql_server.sql.id
  role_definition_name = each.value
  principal_id         = data.azuread_user.user.object_id
}