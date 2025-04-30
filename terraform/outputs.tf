output "resource_group_name" {
    description = "Name of resource group"
    value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
    description = "Name of storage account"
    value = azurerm_storage_account.app_storage.name
}
