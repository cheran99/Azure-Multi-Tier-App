# Azure-Multi-Tier-App

## Introduction

Organisations that rely on monolithic systems tend to struggle with scalability, speed, and security. This leads to increasing costs due to running everything on a single-tier architecture. This project highlights what organisations can do to break out of this cycle by deploying multi-tier applications that scales and secures individual components more seamlessly while being cost-effective and easy to maintain. 

### Objectives
- Deploy a cloud-native, multi-tier web application on Azure that separates the frontend, backend, and database layers.
- Utilise Azure Blob Storage for static web hosting and automated database backups to enhance data availability and resilience.
- Use Terraform and Ansible to automate infrastructure and provisioning, ensuring repeatable, scalable, and secure deployments.

### Tech Stack
- Azure VM (Linux, B1s Free Tier)
- Azure Blob Storage (Static Website Hosting + Backups)
- Flask (Python Web Framework)
- MySQL (Local on VM)
- Terraform (Infrastructure as Code)
- Ansible (Provisioning and Setup)
- Visual Studio Code 

## Deployment Guide

### Setting Up Command Line Interface (CLI) Tools
1. <a href="https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"> Install Azure CLI </a>:
    - Once installed, open Windows PowerShell and log in to Azure using the following command:
      `az login`
      ![image](https://github.com/user-attachments/assets/00ae9c7e-12a7-4651-851a-bf7e3118cedf)

2. <a href="https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"> Install Terraform </a>:
    - To check if Terraform is installed, run the following command:
      `terraform -help`
    - Initialise Terraform using the following command:
      `terraform init`
      ![image](https://github.com/user-attachments/assets/7cf5ffc3-e110-4941-a7ad-2f703e4bb4c9)

3. <a href="https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu"> Install Ansible </a>:

   - Since Windows is being used as the local machine, you will need to install Windows Subsystem for Linux (WSL) first before you install Ansible because the Ansible control node cannot be used in a Windows system. You will need to install and use Ansible inside WSL. To install WSL, go to PowerShell and use the following command:

     ```
     wsl --install
     ```
   - Once WSL is installed and you have created your UNIX username and password, you can now install Ansible using the following commands:
  
     ```
     sudo apt update
     sudo apt install software-properties-common
     sudo add-apt-repository --yes --update ppa:ansible/ansible
     sudo apt install ansible
     ```

### Create GitHub Directory Structure
In this step, the files for Terraform, Ansible, backend, and frontend need to be created. The GitHub directory structure for these files should look like this:

```
Azure-Multi-Tier-App/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── ansible/
│   ├── playbook.yml
│   ├── inventory
├── backend/
│   └── app.py
├── frontend/
│   ├── index.html
│   └── style.css
```

### Provision Infrastructure with Terraform 

Once the files are created, the next step is to clone the repository using the following command:
```
git clone https://github.com/cheran99/Azure-Multi-Tier-App.git
cd Azure-Multi-Tier-App
```

Next, navigate to the Terraform directory using the following command:
`cd terraform` 

Initialise Terraform:
`terraform init`

This will download the required provider plugins and prepares the working directory for Azure platforms.

Open Visual Studio Code, then open the file where the contents of the cloned GitHub repository structure are saved. The directory for this would be: `C:\Windows\System32\Azure-Multi-Tier-App`

![image](https://github.com/user-attachments/assets/5b760b41-caf1-4955-a728-04fd2db4a166)

Go to the Terraform directory and open the `main.tf` file. This is where the Azure Resource Group will be created and configured. 

Use the following configurations:

```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.27.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "multi-tier-rg"
  location = "UK South"
}

resource "azurerm_storage_account" "app_storage" {
  name                     = "mutitierstorcheran"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "blob_container" {
  name                  = "static-assets"
  storage_account_name    = azurerm_storage_account.app_storage.name
  container_access_type = "blob"
}
```

With the above configurations, the Terraform Azure provider is set up, and a resource group, storage account, and blob container for static files or backups are created. 


## References
- https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
- https://developer.hashicorp.com/terraform/cli/run
- https://developer.hashicorp.com/terraform/cli











