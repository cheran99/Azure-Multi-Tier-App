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
      source = "hashicorp/azurerm"
      version = "4.27.0"
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
  name                     = "multitierstorcheran"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "blob_container" {
  name                  = "static-assets"
  storage_account_name    = azurerm_storage_account.app_storage.name
  container_access_type = "blob"
}
```

With the above configurations, the Terraform Azure provider is set up, and a resource group, storage account, and blob container for static files or backups are created. Save the file.

Open the `variables.tf` file. The purpose of this file is to allow the user to parametrise their Terraform configurations to ensure that the values can be easily reused and modified without editing the main files.

Use the following configurations:
```
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
```

Save the `variables.tf` file. 

Next, open the `outputs.tf` file. The purpose of this file is to display the important details about the infrastructure in the command line after you use the `terraform apply` command. 

Use the following configurations:
```
output "resource_group_name" {
    description = "Name of resource group"
    value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
    description = "Name of storage account"
    value = azurerm_storage_account.app_storage.name
}
```

Save the `outputs.tf` file and then initialise Terraform:
`terraform init`
![image](https://github.com/user-attachments/assets/6f2bf84c-0491-4479-8e96-10fccb934f78)

After initialising, create an execution plan that allows you to preview the changes Terraform plans to make to your infrastructure. What Terraform does is read the current state of any existing remote objects to ensure the Terraform state is up to date, notes any differences between the current and previous configurations, and proposes any changes that need to be made before applying them. To do this, run the following command:
`terraform plan`

![image](https://github.com/user-attachments/assets/63eec939-a8f0-4c58-906b-258e0c7ee2c7)
![image](https://github.com/user-attachments/assets/ea7d9325-faa4-43f0-850a-2b61e7edbb4d)
![image](https://github.com/user-attachments/assets/b1d6a89a-64d3-4c08-8f5f-58fde6c8b313)

The output shown above shows a detailed overview that Terraform will create 3 new resources such as the resource group, storage account, and blob container. The output also recommends changes that need to be made to the `main.tf` file before applying them. In this case, the resource argument needs to be changed from `storage_account_name` to `storage_account_id`. This is because the Azure Resource Manager requires this change for versions 5.0+ due to `storage_account_name` being deprecated in favour of `storage_account_id`. Additionally, Azure's API is moving towards using resource IDs instead of plain names. 

This is what the change will look like in the blob container block in the `main.tf` file:
```
resource "azurerm_storage_container" "blob_container" {
  name                  = "static-assets"
  storage_account_id    = azurerm_storage_account.app_storage.id
  container_access_type = "blob"
}
```
Save the file and then reinitialise Terraform: `terraform init`.

Then run the exectution plan again to preview the changes: `terraform plan`
![image](https://github.com/user-attachments/assets/f33b1270-fd68-4221-b0c3-c5306f000612)

As shown above, Terraform shows that there are no changes needed to be made as it will create 3 resources. 

Next, apply the changes Terraform proposed in the execution plan: `terraform apply`

Terraform will create an execution plan, and it will give you a prompt to approve the plan before taking the action to create the 3 resources.

![image](https://github.com/user-attachments/assets/96b9f8fd-c573-4554-b2e8-8b5f76810752)

As shown above, Terraform successfully created 3 resources. 

When you log in to the Azure portal in your browser, the resource group, storage account, and blob container have been successfully integrated:
![image](https://github.com/user-attachments/assets/8258a8e6-aeb6-4827-a586-11aa19727200)
![image](https://github.com/user-attachments/assets/2b4e9cd2-ce93-406b-9f99-d19758c3297d)
![image](https://github.com/user-attachments/assets/0a3ddb3f-2bcc-4ed2-b5d2-fa4f99ab07c8)

### Upload Frontend Files To Azure Blob Storage To Enable Static Web Hosting

Now that the Azure infrastructure has been provisioned with Terraform, and 3 resources have been successfully created as a result, the next step is to enable static web hosting by uploading frontend files to Azure Blob Storage. This would enable users to have a public endpoint to access the frontend through a public URL without requiring the web server to render content. The use of Azure Blob Storage is a cost-efficient way to host static content. 

To enable static web hosting, go to the Azure portal. On the left panel, select "Storage accounts". Once you are on this page, select the storage account created earlier:
![image](https://github.com/user-attachments/assets/84cd4530-7e75-4e6c-bd79-bd240c94c2fc)

Select the "Data management" section on the left panel and then select "Static website":
![image](https://github.com/user-attachments/assets/14b6706c-31c6-4949-9ed5-192f78aec48a)

Set "Static website" to enabled. You will then be asked to specify the index document name, which is `index.html` and is in the `frontend` directory:
![image](https://github.com/user-attachments/assets/e2b08e6d-f35e-4971-933b-b77727b6f140)

Click Save to apply the changes. 

The next step is to upload the frontend files to the `$web` container from a source directory using the Azure CLI. To do this, open PowerShell and log in to Azure using `az login`.

Next, use the following command to upload the frontend files to the `$web` container:
```
az storage blob upload-batch -s <source-path> -d '$web' --account-name <storage-account-name>
```

Replace the `<source-path>` with the `frontend` directory file path on your local machine, which is part of the cloned GitHub repository. Replace the `<storage-account-name>` with the name of the storage account created earlier. The command line should look something like this:
```
az storage blob upload-batch -s "C:\Windows\System32\Azure-Multi-Tier-App\frontend" -d '$web' --account-name multitierstorcheran
```

![image](https://github.com/user-attachments/assets/da438bc8-78b1-4813-89fd-4a506fd186a7)

As shown above, the `frontend` files have successfully been uploaded to the `$web` container, and a primary endpoint URL has been created as shown in the "Static website" section:
![image](https://github.com/user-attachments/assets/7ed0892c-0b42-4d19-9bf8-65f4c372a995)

You can now view your hosted frontend by copying and pasting the primary endpoint URL into your web browser. Since the content in the `index.html` and `style.css` files is empty, the webpage for the static website is currently blank:
![image](https://github.com/user-attachments/assets/fa4a4029-e4b9-45dc-a104-9c3afa660a81)

The next step would be to fill in the contents of the `index.html` and `style.css`. To do this, open Visual Studio Code, and then open the folder for the cloned GitHub repository. Head over to the `frontend` directory, and from there you can edit the `index.html` and `style.css` files:
![image](https://github.com/user-attachments/assets/39d4e613-b6bb-4953-9faa-f71611aa80d5)

Once you fill in the contents of the `index.html` and `style.css` files, disable and then enable the "Static website". Next, reupload the `frontend` files to the `$web` container using Azure CLI. Since the `frontend` files already exist, add `--overwrite` at the end of the command. The command should look something like this:
```
az storage blob upload-batch -s "C:\Windows\System32\Azure-Multi-Tier-App\frontend" -d '$web' --account-name multitierstorcheran --overwrite
```

Once it has been reuploaded, go to the "Static website" and copy and paste the new primary endpoint URL into the browser. The webpage should look something like this based on the configurations made to the `index.html` and `style.css` files:

![image](https://github.com/user-attachments/assets/868536a2-7c39-4935-a585-0a640929bd96)



## References
- https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
- https://developer.hashicorp.com/terraform/cli/run
- https://developer.hashicorp.com/terraform/cli
- https://developer.hashicorp.com/terraform/cli/commands/plan
- https://spacelift.io/blog/terraform-tutorial
- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website
- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-portal#upload-files
- https://www.browserstack.com/guide/build-a-website-using-html-css
- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website-host











