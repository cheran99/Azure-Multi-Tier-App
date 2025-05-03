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

resource "azurerm_service_plan" "app_service_plan" {
  name                = "appserviceplan-multitier"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "backend_app" {
  name                = "multitier-backend-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id = azurerm_service_plan.app_service_plan.id

  site_config {}
}



