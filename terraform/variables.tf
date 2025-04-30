variable "location" {
    description = "Region to deploy resources in"
    type = string
    default = "UK South"
}

variable "resources_group_name" {
    description = "Name of resource group"
    type = string
    default = "multi-tier-rg"
}

variable "storage_account_name" {
    description = "Globally unique name of storage account"
    type = string
    default = "multitierstorcheran"
}

variable "container_name" {
    description = "Name of blob storage container"
    type = string
    default = "static-assets"
}