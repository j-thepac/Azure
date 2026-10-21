
#Create A/c in Azure : 
    #  Create dummy User in ENtraID 
    #  Add above user to dummy Group 
    #  Create Resource Group ,add blob contributor 
    #  Add dummy Group to Resource Group and use the below
# $az login #dummy user
# $terraform import azurerm_resource_group.rg /subscriptions/409c82a5-bbbb-4516-93db-5cd3c7eba263/resourceGroups/test_resource_group


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

resource "azurerm_resource_group" "rg" {
  name     = "test_storage_group"
  location = "East US"
}

data "azuread_user" "test" {
  user_principal_name = "test@jthepacgmail.onmicrosoft.com"
}

resource "azurerm_storage_account" "storage" {
  name                            = "gen2teststorage123"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "container" {
  name                  = "testcontainer"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "storage_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.test.object_id
  principal_type       = "User"
}

output "dfs_endpoint" {
  value = azurerm_storage_account.storage.primary_dfs_endpoint
}
