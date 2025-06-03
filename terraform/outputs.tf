output "resource_group_name" {
    description = "Name of resource group"
    value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
    description = "Name of storage account"
    value = azurerm_storage_account.app_storage.name
}

output "azurerm_mysql_flexible_server" {
  value = azurerm_mysql_flexible_server.multi_tier_mysql.name
}

output "mysql_flexible_server_database_name" {
  value = azurerm_mysql_flexible_database.multi_tier_db.name
}

output "administrator_login" {
  value = "admin_${random_string.admin_username.result}"
}

output "administrator_password" {
  sensitive = true
  value =  random_password.admin_password.result
}