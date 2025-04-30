terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.27.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "28f69283-1bf5-44b4-bd20-e11ff721b9c2"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "multi-tier-rg"
  location = "UK South"
}

resource "azurerm_storage_account" "app_storage" {
  name                     = "multitierstorcheran"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "blob_container" {
  name                  = "static-assets"
  storage_account_id    = azurerm_storage_account.app_storage.id
  container_access_type = "blob"
}
