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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    } 
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "multi-tier-rg"
  location = "UK West"
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
  
  app_settings = {
    AZURE_MYSQL_HOST        = "multitier-mysql.mysql.database.azure.com"
    AZURE_MYSQL_USER        = "admin_${random_string.admin_username.result}"
    AZURE_MYSQL_PASSWORD    = random_password.admin_password.result
    AZURE_MYSQL_NAME        = "multitierdb"
  }

  identity {
    type = "SystemAssigned"  
  }

  depends_on = [azurerm_key_vault_secret.mysql_password_secret]
}

resource "random_string" "admin_username" {
  length           = 12
  upper            = false
  lower            = true
  numeric          = true
  special          = false
}

output "admin_username" {
  value = "admin_${random_string.admin_username.result}"
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_virtual_network" "mysql_vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = "mysql-vnet"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.mysql_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "mysqlDelegation"

    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql_private_dns" {
  name                = "${random_string.admin_username.result}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_vnet_link" {
  name                  = "mysqlfsVnetZone${random_string.admin_username.result}.com"
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns.name
  virtual_network_id    = azurerm_virtual_network.mysql_vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_mysql_flexible_server" "multi_tier_mysql" {
  name                   = "multitier-mysql"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "admin_${random_string.admin_username.result}"
  administrator_password = random_password.admin_password.result
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.mysql_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_private_dns.id
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"

  storage {
    size_gb              = 20
    auto_grow_enabled    = true
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_vnet_link]
  
  lifecycle {
    ignore_changes = [location, sku_name, backup_retention_days]
  }
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_ips" {
  name                = "allow_azure_ips"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.multi_tier_mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_flexible_database" "multi_tier_db" {
  name                = "multitierdb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.multi_tier_mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "mysql_key_vault" {
  name                        = "mysql-kv-${random_string.admin_username.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

resource "azurerm_key_vault_secret" "mysql_password_secret" {
  name         = "mysql-password"
  value        = random_password.admin_password.result
  key_vault_id = azurerm_key_vault.mysql_key_vault.id
}

data "azurerm_linux_web_app" "backend_app_data" {
  name                = azurerm_linux_web_app.backend_app.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_key_vault_access_policy" "app_service_access" {
  key_vault_id = azurerm_key_vault.mysql_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_linux_web_app.backend_app_data.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}