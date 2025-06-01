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
![image](https://github.com/user-attachments/assets/05fc6a07-04a5-411b-802d-77ad94634b1e)
![image](https://github.com/user-attachments/assets/1a32a1bd-e1e5-4c65-8afb-a4d36e5afd82)
![image](https://github.com/user-attachments/assets/5ca5b8dc-1e94-404b-be33-5a5273b0b863)


### Upload Frontend Files To Azure Blob Storage To Enable Static Web Hosting

Now that the Azure infrastructure has been provisioned with Terraform, and 3 resources have been successfully created as a result, the next step is to enable static web hosting by uploading frontend files to Azure Blob Storage. This would enable users to have a public endpoint to access the frontend through a public URL without requiring the web server to render content. The use of Azure Blob Storage is a cost-efficient way to host static content. 

To enable static web hosting, go to the Azure portal. On the left panel, select "Storage accounts". Once you are on this page, select the storage account created earlier:
![image](https://github.com/user-attachments/assets/37266be5-dcec-4f74-9bb7-7ee7fe10d75a)

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

### Provision Azure App Service Plan and Linux Web App with Terraform

Since the Azure App Service Plan and Linux Web App was not defined with Terraform earlier, that will need to be provisioned first before deploying backend configurations with Ansible to Azure App Service.

To do this, log in to WSL on PowerShell. Then navigate to the cloned GitHub directory, and then to the Terraform directory. Once you are in this directory, initialise Terraform using the `terraform init` command. 

Open Visual Studio Code, then open the folder that has the contents of the cloned GitHub repository, which is the `Azure-Multi-Tier-App` folder. Go to the `terraform` directory, open the `main.tf` file and add the following configurations:
```
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
```

Next, create an execution plan using the following command:
```
terraform plan -lock=false
```

The reason why `-lock=false` is added to the command is that the permissions for the `terraform.tfstate` only contain read-only permissions, therefore, the lock for the `.tfstate` file needs to be unlocked so that the App Service and App Service Plan can be provisioned with Terraform. Disabling the lock is not recommended, especially in shared environments, because if multiple users or processes modify the state file simultaneously, this can potentially cause state corruption. Since this project is a low-scale project involving only one user, disabling the lock is safe.

Once Terraform shows the proposed changes in the execution plan, apply the changes using the following command:
```
terraform apply -lock=false
```

When prompted, type "yes". This will create 2 resources, the App Service Plan and the Linux Web App Service for the backend app. 

![image](https://github.com/user-attachments/assets/6aa24807-d759-4a10-af4f-ab060fe990ee)

![image](https://github.com/user-attachments/assets/effd926d-b856-43e7-beb4-1f4e0c22d820)

On the Linux Web App Service page, go to "Settings", then to "Configuration". On the "Stack Settings", set them to Python along with the latest major and minor versions:
![image](https://github.com/user-attachments/assets/7db947ac-d5ce-491d-ae7a-598284168d39)

Once the runtime stack is set, you can save the configuration. The reason why the runtime stack should be Python is that the backend application is a Flask application that runs on Python. 

### Configure Backend Application

This step will involve adding a basic Flask backend code to the `app.py` file so that the Azure App Service has something to run when the backend is deployed.

Before adding content to the `app.py` file, install Flask on the local machine if you haven't already done so. You can do this on the PowerShell using the following command:
```
pip install flask
```

Ensure that the `pip` command is the latest version.

Open Visual Studio Code, and then open the `Azure-Multi-Tier-App` repository. Head over to the `backend` directory and write the following configurations in the `app.py` file:
```
from flask import Flask, render_template
import os

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/health")
def health_check():
    return "Backend is running"

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port)
```

The code above ensures that the backend serves the frontend in a multi-tier application.

For the backend code to function properly, a `requirements.txt` file must also be in this `backend` directory. The `requirements.txt` file lists all the dependencies that Azure App Service needs to install when the backend code is deployed to the server.

On the `backend` directory in Visual Studio Code, create a `requirements.txt` file. The list of dependencies in this file includes all the Python packages, including Flask. Ensure to include their version number. To check this, open PowerShell and run the following command:
```
flask --version
```

This will give the following output:
```
Python 3.10.1
Flask 3.0.2
Werkzeug 3.0.1
```
Add Flask and Werkzeug, along with their version numbers, to the `requirements.txt` file. The file should look something like this:
```
Flask==3.0.2
Werkzeug==3.0.1
```

Create two sub-directories in the `backend` directory and label them as `static` and `templates`. The `template` folder should have the `index.html` file created earlier, and the `static` folder should have the `style.css` file that was also created earlier. 

### Deploy Backend with Ansible to Azure App Service

Now that the Azure App Service Plan and Linux Web App Service have been provisioned with Terraform and the backend code has been configured, the next step would be to utilise Ansible to deploy the backend application to Azure App Service. This step will ensure that the configuration and deployment of the backend code to Azure App Service are automated and repeated without manual intervention. This allows easier management of deployments across multiple environments and easier integrations with CI/CD pipelines.

Open PowerShell, and log in to WSL using the following command:
```
wsl -d Ubuntu
```

Once logged in, install Ansible using the following command if you haven't done so:
```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

Next, install Azure Collection for Ansible using the following command. Modules to manage Azure resources are included in this collection:
```
ansible-galaxy collection install azure.azcollection --force
```

Create a service principal to enable authentication with Ansible using the following command:
```
az ad sp create-for-rbac --name ansible-backend --role contributor --scopes /subscriptions/mySubscriptionID/resourceGroups/myResourceGroupName
```

Replace `mySubscriptionID` with your Azure subscription ID used to create the resources. Replace `myResourceGroupName` with the resource group created earlier. This will create a service principal identity that allows Ansible authenticated access to Azure resources. You can find the subscription ID in the Azure portal.

Once you have created the service principal using the command shown above, you will be provided with the `appID`, `displayName`, `password`, and `tenant`. The `appID` is the service principal application ID, and `tenant` is the tenant ID.  

The next step is to set the environmental variables by exporting your service principal values so that Ansible can use them. This is done using the following commands:
```
export AZURE_SUBSCRIPTION_ID=<subscription_id>
export AZURE_CLIENT_ID=<appID>
export AZURE_SECRET=<password>
export AZURE_TENANT=<tenant>
```

Ensure the `backend` files in the `Azure-Multi-Tier-App` repository include the following:
- `app.py`
- `requirements.txt`
- `templates/index.html`
- `static/style.css`

On the same terminal in PowerShell, navigate to the cloned GitHub repository and then to the `backend` directory using the following command:
```
cd "Azure-Multi-Tier-App/backend"
```

Create a ZIP file package for the backend file so that the application can be deployed to Azure App Service. To create the ZIP file, run the following command:
```
zip -r backend.zip .
```

Open Visual Studio Code, and then open the `Azure-Multi-Tier-App` repository. Head over to the `ansible` directory and write the following configurations in the `backend_play.yml` file:
```
- name: Deploy backend to Azure App Service 
  hosts: localhost
  connection: local

  tasks:
    - name: Deploy ZIP Package using Azure CLI
      command: >
        az webapp deploy 
        --resource-group multi-tier-rg
        --name multitier-backend-app
        --src-path "C:/Windows/System32/Azure-Multi-Tier-App/backend.zip"
```

This will deploy the backend application from the ZIP package to the Azure App Service. 

On the same terminal in PowerShell, change the directory to the `ansible` directory using the following commands:
```
cd ..
cd ansible
```

Run the playbook file (`backend_play.yml`) using the following command:
```
ansible-playbook backend_play.yml
```

This will give the following output:
![image](https://github.com/user-attachments/assets/bd405719-2f92-417f-bfc7-f9e6d92e5acd)

To verify that the web app is working with both the frontend and backend deployed, go to the Azure portal using the credentials created earlier and go to the `multitier-backend-app` created earlier. Next, click the default domain to see the output for the web app:

![image](https://github.com/user-attachments/assets/b3d7de0d-02f6-4aa3-ab53-3aa7dbcffc78)

The output shown above is the main page for the web app. To check the health of the web application, add `/health` at the end of the URL as defined by the `@app.route("/health")` in the `app.py` file:

![image](https://github.com/user-attachments/assets/d6db4b6b-898a-45ff-bc0a-30c219ae7e1e)

### Connecting Frontend to Backend

Since the frontend files have been deployed to the Azure Blob Storage, and the backend files have been deployed to the Azure App Service, the next step would be to configure the frontend files so that it  knows how to communicate with the backend. 

Open Visual Studio Code, then open the `Azure-Multi-Tier-App` repository. Head over to the `frontend` directory and open the `index.html` file. Add the following configurations to the file to ensure that it has the API URL for the Linux Web App:
```
<script>
    fetch("https://multitier-backend-app.azurewebsites.net/health")
        .then(response => response.text())
        .then(data => { 
            document.getElementById("api-response").innerText = data
        })
        .catch(error => {
            console.error("Backend failed to run", error);
            document.getElementById("api-response").innerText = "Unable to connect to backend.";
        });
</script>
```

Save the file. 

The next step is to redeploy the frontend files to Azure Blob Storage using the following command on PowerShell:
```
az storage blob upload-batch -s "C:\Windows\System32\Azure-Multi-Tier-App\frontend" -d '$web' --account-name multitierstorcheran --overwrite
```
Go to the Azure portal, then to the storage account, and then to the "Static website" page. Once you are on this page, disable and then enable the static website. This will refresh the primary endpoint URL.

The next step is to configure CORS on the Azure App Service. CORS stands for cross-origin resource sharing, and it is a security mechanism that controls how resources can be fetched from different external domains. This prevents unauthorised domains from accessing sensitive information without permissions. In this project, CORS is being integrated into the Linux Web App so that it can be configured to allow the frontend to fetch data from the backend.  

To do this, go to the web app in the Azure portal, then to "API" and then to "CORS":
![image](https://github.com/user-attachments/assets/72102f0f-4783-4446-a1af-051d34a4fc96)

Add the primary endpoint URL for the frontend static website to the "Allowed Origins" area so that the frontend can fetch data from the backend. Click "Save". This will properly connect the frontend to the backend. 

To verify the connectivity, copy and paste the primary endpoint URL for the frontend static website into the web browser. Once you are on the page, right-click and then select "Inspect" or "Inspect Element". Go to the "Network" tab and refresh it. This will give you the following result:

![image](https://github.com/user-attachments/assets/7e2b9d38-67cb-45a6-9584-df78388d811f)

Click on "health". This will show you that the status code is 200, meaning that the connection is successful. The primary endpoint URL is shown in the "Access-Control-Allow-Origin" under the "Response Headers" section, which verifies that the frontend is allowed to fetch resources from the backend. Under the "Request Headers" section, the host is shown to have the URL for the Linux Web App domain, while the origin is shown to have the primary endpoint URL for the frontend static website:

![image](https://github.com/user-attachments/assets/f84f1185-7337-404b-ba28-7416f3f6bd81)

This verifies that the frontend is properly connected to the backend. 

### Setting Up A SQL Database and Secure Connection

The next step would be to set up an Azure database using Azure MySQL and establish a secure connection between the database and the backend application. This ensures that data is stored and managed by the backend using Azure MySQL, and that only authorised services can access it. 

The Azure MySQL will need to be provisioned using Terraform. The type of server used for MySQL will be a flexible server over a single server. The reason why the flexible server is chosen is that it has more depth, enhanced storage options, high availability, and better scalability compared to a single server. A flexible server is an essential requirement to run a scalable and reliable multi-tier application.

To provision the Azure MySQL with Terraform, log in to WSL on PowerShell. Then navigate to the `Azure-Multi-Tier-App` repository, and then to the Terraform directory. Once you are in this directory, initialise Terraform using the `terraform init` command. 

In Visual Studio Code, open the `Azure-Multi-Tier-App` repository. Go to the `terraform` directory. Open the `main.tf` file and add the following resources:
```
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
```

This will not only create a MySQL flexible server and database, but it will also create a virtual network, firewall, subnet, and private DNS for extra security. Save the file.

Open the `outputs.tf` file and add the following code:
```
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
```

Next, create an execution plan using the following command:
```
terraform plan 
```

This will give a preview of what Terraform plans to create to change the infrastructure.

Next, apply the changes using the following command:
```
terraform apply
```
When prompted, type "yes" to approve the change. 

To verify that Terraform has created the resources, log in to the Azure portal, then head over to the resource group. You can see that the MySQL flexible server, virtual network, virtual network link, and private DNS zone have been created:

![image](https://github.com/user-attachments/assets/61e7536a-fa7c-4c46-af9e-8e5f8fa651b4)

To check if the subnet has been created, go to the `mysql-vnet` virtual network that was created earlier. Once you are on this page, on the left panel, go to "Settings", then to "Subnets". You will see the subnet that was provisioned using Terraform:

![image](https://github.com/user-attachments/assets/339b9c05-6581-47e1-b7d1-d7537ba8a24c)

To verify is the Azure MySQL flexible database has been created, go to the `multitier-mysql` flexible server, then to "Settings" on the left panel, and then to "Databases". You can see that the flexible database has been created:

![image](https://github.com/user-attachments/assets/19aa43eb-4679-416b-a2d8-6f0b2945a95f)

### Creating Tables in Azure Database for MySQL Flexible Server

Now that the MySQL flexible server and database have been created, the next step is to create tables so that the database can store data, the backend application can query and manipulate data, and enable the data to be efficiently structured and organised, which is essential for scaling the app.

Go to the Azure portal, then to `multitier-mysql` flexible server. Go to "Networking". You can see that the server only has private access, meaning that only resources within the same private virtual network or peering virtual networks have access to this MySQL flexible server. Because of this, the local machine or Azure Cloud Shell cannot connect to this server, therefore the tables cannot be created. 

To allow public access, select "Move to Private Link" in the "Networking" tab. A warning will appear and you will be prompted to click "Yes" or "No". Click "Yes". This will take you to the following page:

![image](https://github.com/user-attachments/assets/462250db-4b21-473f-b041-66562b36d590)

Tick the box under "Public access" and then click "Next". This will detach the server from the virtual network and also enable the local machine or Cloud Shell to connect to the server.

Next, open PowerShell and login to WSL using the following command:
```
wsl -d Ubuntu
```

Install the MySQL client using the following commands:
```
sudo apt-get update
sudo apt-get install mysql-client
```

You can connect to the Azure MySQL flexible server using the following command:
```
mysql -h <server address) -P 3306 -u <your username> -p
```

You will be prompted to enter the administrator password generated earlier with Terraform. 

Once you have successfully connected to the MySQL server, select the MySQL flexible database that was created earlier which is `multitierdb`. Use the following command:
```
USE multitierdb;
```

This will change the database to `multitierdb`. Create a `app_user` table using the following code:
```
CREATE TABLE app_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    car_brand VARCHAR(100)
);
```

To verify that the table has been created, run the following queries:
```
SHOW TABLES;
DESCRIBE app_user
```

The output should look something like this:
```
+-----------+--------------+------+-----+---------+----------------+
| Field     | Type         | Null | Key | Default | Extra          |
+-----------+--------------+------+-----+---------+----------------+
| id        | int          | NO   | PRI | NULL    | auto_increment |
| name      | varchar(100) | YES  |     | NULL    |                |
| gender    | varchar(10)  | YES  |     | NULL    |                |
| age       | int          | YES  |     | NULL    |                |
| car_brand | varchar(100) | YES  |     | NULL    |                |
+-----------+--------------+------+-----+---------+----------------+
5 rows in set (0.06 sec)
```


### Configuring The Backend To Connect To MySQL

This step involves configuring the backend code so that it connects to the MySQL database. The purpose of this step is to ensure that the backend Flask application serves dynamic responses by performing database operations such as creating, reading, updating, and deleting data. In a multi-tier application, this step is essential to ensure secure communication between the backend and the database. 

Open PowerShell and install the MySQL Connector Python package using the following command:
```
pip install mysql-connector-python
```

Open Visual Studio Code and head over to the `Azure-Multi-Tier-App` repository, and then to the `backend` directory. Open the `requirements.txt` file and add `mysql-connector-python` to the list along with its version number. Once you have done this, save the file. 

Next, open the `app.py` file and add the following codes so it looks something like this:
```
from flask import Flask, render_template, jsonify, request 
import os
import mysql.connector

app = Flask(__name__)

host = os.getenv('AZURE_MYSQL_HOST')
user = os.getenv('AZURE_MYSQL_USER')
password = os.getenv('AZURE_MYSQL_PASSWORD')
database = os.getenv('AZURE_MYSQL_NAME')
ssl_cert_path = os.path.join(os.path.dirname(__file__), "certs", "DigiCertGlobalRootCA.crt.pem")

def get_db_connection():
    try:
        cnx = mysql.connector.connect(
            user=user, 
            password=password, 
            host=host, 
            port=3306, 
            database=database, 
            ssl_ca=ssl_cert_path,
            ssl_disabled=False
        )
        print("Database connection successful.")
        return cnx
    except mysql.connector.Error as err:
        print(f"Database Connection Error: {err}")
        return None   
        

@app.route("/", methods = ['GET', 'POST'])
def index():
    conn = get_db_connection()
    if not conn:
        return "Database connection failed", 500
    
    cursor = conn.cursor()
    

    if request.method == 'POST':
        name = request.form['name']
        gender = request.form['gender']
        age = request.form['age']
        car_brand = request.form['car_brand']
        
        query = "INSERT INTO app_user (name, gender, age, car_brand) VALUES (%s, %s, %s, %s);"
        values = (name, gender, age, car_brand)
        cursor.execute(query, values)
        conn.commit()

    cursor.execute("SELECT * FROM app_user") 
    results = cursor.fetchall()
    
    cursor.close()
    conn.close()    
    return render_template("index.html", results=results)

@app.route("/submit", methods=["POST"])
def submit():
    print("Thank you for submitting")

@app.route("/health")
def health_check():
    return "Backend is running"

@app.route("/data")
def get_data():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if conn:
        cursor.execute("SELECT * FROM app_user") 
        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify({"data": data})
    else:
        return jsonify({"error": "Failed to connect to database"}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port)
```

Save the file. 

### Configuring The Frontend To Connect To MySQL

Since the Flask application involves the user inserting information into the database, the frontend files also needs to be configured to reflect this change. To do this, on Visual Studio Code, go to the `frontend` directory in the `Azure-Multi-Tier-App` repository, open the `index.html` file and add the following code:
```
<h2>
    Enter User Information
</h2>

<form action="/" method="POST">
    <label>Name:</label>
    <input type="text" name="name" required><br>
  
    <label>Gender:</label>
    <select name="gender" required>
      <option value="Male">Male</option>
      <option value="Female">Female</option>
      <option value="Other">Other</option>
    </select><br>
  
    <label>Age:</label>
    <input type="number" name="age" required><br>
  
    <label>Favourite Car Brand:</label>
    <input type="text" name="car_brand" required><br>
  
    <button type="submit">Submit</button>
</form>

<h3> Submitted Users </h3>
{% if results %}
<table>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Gender</th>
        <th>Age</th>
        <th>Car Brand</th>
    </tr>
    {% for row in results %}
    <tr>
        <td>{{ row[0] }}</td>
        <td>{{ row[1] }}</td>
        <td>{{ row[2] }}</td>
        <td>{{ row[3] }}</td>
        <td>{{ row[4] }}</td>
    </tr>
    {% endfor %}
</table>
{% else %}
    <p>No records found.</p>
{% endif %}
</body>
</html>
```
This will display the form for the user to fill in the information, which will then be added to the database. The table will display the information added. Save the file. 

Next, open the `style.css` file and add the following configurations so that the form and table look neat and presentable:
```
form {
    background-color: rgb(31, 220, 226);
    text-align: center;
    padding: 20px;
    margin: 30px auto;
    margin-top: 5px;
    width: 500px;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(17, 17, 17, 0.1);
}

form button {
    width: 100px;
    padding: 10px;
    background-color: chocolate;
    margin-top: 10px;
    border-radius: 8px;
    font-weight: bold;
    cursor: pointer;
    font-size: 16px;
}

form label {
    display: block;
    margin-bottom: 5px;
    font-weight: 600;
    color: #333;
}

form input [type='text'] {
    width: 100%;
    padding: 10px;
    margin-bottom: 15px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
    font-size: 14px;
}

form input [type='number'] {
    width: 100%;
    padding: 10px;
    margin-bottom: 15px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
    font-size: 14px;
}

form select {
    width: 100%;
    padding: 10px;
    margin-bottom: 15px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
    font-size: 14px;
}

table {
    width: 100%;
    border-collapse: collapse;
    background-color: #fff;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
    border-radius: 6px;
    overflow: hidden;
}

table th, table td {
    padding: 12px 15px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

table th {
    background-color: #2980b9;
    color: white;
    text-transform: uppercase;
    font-size: 14px;
}

table tr:hover {
    background-color: #f1f1f1;
}

h2 {
    text-align: center;
    font-style: oblique;
    font: bolder;
    font-family: Arial, Helvetica, sans-serif;
    color: rgb(5, 11, 95);
}

h3 {
    text-align: center;
    font-style: oblique;
    font: bolder;
    font-family: Arial, Helvetica, sans-serif;
    color: rgb(46, 82, 54);
}
```

Save the file. Ensure that the `index.html` and `style.css` files in the backend directory also have these new configurations. 

The next step is to redeploy the frontend files to Azure Blob Storage using the following command on PowerShell:
```
az storage blob upload-batch -s "C:\Windows\System32\Azure-Multi-Tier-App\frontend" -d '$web' --account-name multitierstorcheran --overwrite
```

On PowerShell, change the directory to the `backend` directory. Once you are in this directory, create the ZIP file using the following command:
```
zip -r backend.zip .
```

Move the ZIP file to the main directory. 

### Provision Azure Key Vault And Add Environmental Variables To The Linux Web App With Terraform

The next step is to go to the `terraform` directory and open the `main.tf` file. Head over to the "azurerm_linux_web_app" resource block and add the following environmental variables under this resource:
```
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
```

This will ensure that the Linux Web App uses the MySQL server credentials to connect to the database and store the user's data there. 

You will also need to add Azure Key Vault as a resource in Terraform, which is where sensitive information like the MySQL administrator password would be stored. To do this, add the following code in the `main.tf` file:
```
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
```

On PowerShell, change the directory to the `terraform` directory and run the following commands:
```
terraform init
terraform plan
terraform apply
```

This will update and create the resources. To verify its creation, go to the Azure portal, then to the Key vaults directory. You will see that the key vault has successfully been created:

![image](https://github.com/user-attachments/assets/ef2f880d-517e-4bce-913e-634da6677eac)

To check if the key vault secret has been created, click on the created key vault. Once you are on this key vault page, go to "Objects" and then to "Secrets". You can see that the key vault secret for the MySQL administrator password has successfully been created:

![image](https://github.com/user-attachments/assets/e3e377e6-aab9-48a2-9f26-8f70defe9200)

If you want to view the password, click the key vault secret, then click the current version. This will take you to a page where you can view the secret value of the password as shown below:

![image](https://github.com/user-attachments/assets/dfc67e3a-b366-4412-abe0-69f28b8d5c85)


To check if the access policies for the key vault have been created, go to "Access policies" on this key vault page. It should look something like this:

![image](https://github.com/user-attachments/assets/c20943ca-e972-4168-a5b4-c85113a58aed)


To check if the environmental variables have been added under the app settings, go to `multitier-backend-app`, then to "Settings", and then to "Environment variables". It should look something like this:

![image](https://github.com/user-attachments/assets/2cb6ab43-91aa-4cb1-a071-8fc64fc8bab7)

### Redeploying The Updated ZIP File To The Linux Web App Using Ansible

Before deploying the `backend.zip` file using Ansible to the Linux Web App, go to the App Service on the Azure Portal, then to "Settings", and then to "Environmental Variables". Click "Add" and add the following application setting, and set the value to 1 or 'True':
```
SCM_DO_BUILD_DURING_DEPLOYMENT = 1
```
This process will ensure that Oryx will create a virtual environment and install the required packages on the web app whenever a deployment occurs. 

Add the following code in the `backend_play.yml` playbook:
```
- name: Set startup command
      command: >
        az webapp config set
        --resource-group multi-tier-rg
        --name multitier-backend-app
        --startup-file "python app.py"
```
This will ensure that the Flask application starts when the ZIP file is deployed to the web app. 

The next step is to change the directory to the `ansible` directory in the WSL terminal and run the playbook using the following command:
```
cd ansible
ansible-playbook backend_play.yml
```

![image](https://github.com/user-attachments/assets/32d021b5-2193-4961-a8d7-dcbbed004696)

The output shows that the web app deployment has been successful.

To see if the web app is working with the new backend code deployed, go to the `multitier-backend-app` web app on the Azure portal, and click on the default domain link to see the output. The output should look something like this:
![image](https://github.com/user-attachments/assets/5f465893-c31f-419f-a0d6-172a4c25c5c8)

Now to check if the form on the application is working and and adding the entered information to the table, you can add more user information just to play around with it and see the results:

![image](https://github.com/user-attachments/assets/55e03552-96ac-4d3e-85ff-d6d93deead4b)

As shown above, the form is working and the data is stored in the table below. 

To verify that the input data has successfully been stored in the MySQL flexible server, log in to the server using the following command:
```
mysql -h <server address) -P 3306 -u <your username> -p
```

When prompted, enter the administrator password. 

Once you are logged in, run the following SQL query to view the new data:
```
USE multitierdb;
SELECT * FROM app_user;
```

The output should look something like this:

![image](https://github.com/user-attachments/assets/864db535-f0dc-4f9e-8f24-1edf8b784d79)

This shows that the data entered by the user from the web app has successfully been stored in the specific database on the MySQL flexible server. 

If you add `/data` at the end of the URL for the web app domain, that will show you the data entered by the user:

![image](https://github.com/user-attachments/assets/1d808548-ad28-4aa6-80db-350535e0873f)


### Securing The Architecture Of The Multi-Tier Application 

Remember when the MySQL flexible server was changed to public access earlier, so it was easier to connect to the server, create and destroy tables, and view the data stored in them in the database? Well, the MySQL flexible server will now be changed back to private access to ensure that the risk of unauthorised access or attacks is significantly reduced, and only resources within the Azure Virtual Network have access to the server, enhancing security in the process. 

On the Azure portal, go to the MySQL flexible server, which is `multitier-mysql`. Once you are on this page, go to "Settings", then to "Networking". Disable public access by unticking the box and click "Save". At the bottom of the "Networking" page, click "Create private endpoint".

![image](https://github.com/user-attachments/assets/1aac54eb-66c4-4403-92fe-b588060c0c75)

Ensure that the private endpoint is under the same `multi-tier-rg` resource group, and also the same region as the other resources, such as the virtual network. Click "Next", and when you reach the "Virtual Network" page, select the virtual network and subnet that was provisioned earlier with Terraform. Leave everything else to its default and continuously click "Next" until you reach the page where it shows the outputs for the private endpoint, such as the basics, resource, virtual network, and DNS. If you are happy with the outputs, click "Create", and the private endpoint will be created. 

![image](https://github.com/user-attachments/assets/e84c86b8-d750-4890-86b7-3ab278444d79)

Once the private endpoint has been deployed, go to the `multitier` private endpoint page, then to "Settings", and then to "DNS Configuration". Click "Add configuration" and select the private DNS zone that was provisioned earlier with Terraform, and click "Add":

![image](https://github.com/user-attachments/assets/69319494-9b3e-4fee-a157-30f4076779c9)

The chosen private DNS zone is linked to the virtual network as defined by Terraform.

Go to the `mysql-vnet` virtual network page, and then to "Subnets". Create a new subnet for the App Service to enable outbound connections to the MySQL flexible server. Name this subnet `backend-subnet`. Keep every other configuration to its default and click "Add":

![image](https://github.com/user-attachments/assets/46ad148e-e1c6-451c-a7f6-9efc2096e395)

Next, go to the `multitier-backend-app` web app page, and then to the "Networking" page. On the "Outbound traffic configuration" section, configure the virtual network integration. Select the `mysql-vnet` virtual network as well as the `backend-subnet` and click "Connect":

![image](https://github.com/user-attachments/assets/a6317091-4be9-40f7-8764-aee5159ee168)

This will connect the App Service to the same virtual network as the MySQL flexible server. 

Now let's access the domain for the Linux Web App. As shown below, the web app is successfully working:

![image](https://github.com/user-attachments/assets/d8d70f83-82bc-445c-83c6-d73b4179a727)

This shows that the web app can successfully connect to the MySQL flexible server even with public access disabled because both the App Service and MySQL server are part of the same virtual network. 

If you try connecting to the server using PowerShell or the MySQL Workbench application from your local machine, it gives an error message:

![image](https://github.com/user-attachments/assets/273d1606-ffaf-41ba-aa89-03dda14db4d4)

![image](https://github.com/user-attachments/assets/2f988bd1-74b9-4873-abe6-4cd20e66ca56)

As a result, the MySQL flexible server is now secure from public exposure. 

The only way that you can privately access the server is through a virtual machine that is part of the same virtual netowrk as the server. 




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
- https://learn.microsoft.com/en-us/azure/app-service/provision-resource-terraform
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service.html
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app
- https://galaxy.ansible.com/ui/repo/published/azure/azcollection/
- https://learn.microsoft.com/en-us/azure/developer/ansible/install-on-linux-vm?tabs=azure-cli#install-ansible-on-an-azure-linux-virtual-machine
- https://learn.microsoft.com/en-us/cli/azure/azure-cli-sp-tutorial-1?wt.mc_id=searchAPI_azureportal_inproduct_rmskilling&sessionId=cbce6ec3338248c0be2c8463c754def8&tabs=powershell
- https://learn.microsoft.com/en-us/azure/developer/ansible/azure-web-apps-configure
- https://docs.ansible.com/ansible/latest/collections/azure/azcollection/index.html#plugin-index
- https://www.tutorialspoint.com/yaml/yaml_scalars_and_tags.htm#:~:text=YAML%20flow%20scalars%20include%20plain,always%20folded%20in%20this%20structure.
- https://learn.microsoft.com/en-us/azure/app-service/deploy-zip?tabs=cli
- https://spacelift.io/blog/ansible-variables
- https://learn.microsoft.com/en-us/cli/azure/webapp/deployment/source?view=azure-cli-latest#az-webapp-deployment-source-config-zip
- https://flask.palletsprojects.com/en/stable/installation/
- https://flask.palletsprojects.com/en/latest/quickstart/#a-minimal-application
- https://www.geeksforgeeks.org/flask-rendering-templates/
- https://github.com/Azure-Samples/python-docs-hello-world/blob/master/app.py
- https://realpython.com/python-web-applications/
- https://learn.microsoft.com/en-us/cli/azure/webapp/deployment/source?view=azure-cli-latest#az-webapp-deployment-source-config-zip
- https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_webapp_module.html#ansible-collections-azure-azcollection-azure-rm-webapp-module
- https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_appserviceplan_module.html#ansible-collections-azure-azcollection-azure-rm-appserviceplan-module
- https://www.youtube.com/watch?v=ujiJaz2bRII
- https://medium.com/swlh/making-use-of-apis-in-your-front-end-c168e343bea3
- https://www.digitalocean.com/community/tutorials/how-to-use-the-javascript-fetch-api-to-get-data
- https://medium.com/%40mterrano1/cors-in-a-flask-api-38051388f8cc
- https://www.geeksforgeeks.org/how-to-install-flask-cors-in-python/
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server
- https://learn.microsoft.com/en-us/azure/mysql/flexible-server/quickstart-create-terraform?tabs=azure-cli
- https://blobeater.blog/2022/01/19/azure-db-for-mysql-single-server-vs-flexible/#:~:text=Microsoft%20position%20flexible%20server%20as,service%20designed%20for%20minimal%20customization.
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule
- https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
- https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
- https://dev.mysql.com/doc/connector-python/en/quick-installation-guide.html
- https://www.youtube.com/watch?v=c8r5BLoRAwg
- https://learn.microsoft.com/en-us/azure/service-connector/how-to-integrate-mysql?tabs=python
- https://learn.microsoft.com/en-us/azure/app-service/reference-app-settings?tabs=kudu%2Cdotnet
- https://www.geeksforgeeks.org/profile-application-using-python-flask-and-mysql/
- https://medium.com/@connect.hashblock/creating-an-api-in-flask-with-mysql-a-step-by-step-guide-446f08722057
- https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-network-from-private-to-public
- https://www.geeksforgeeks.org/mysql-create-table/
- https://www.w3schools.com/mysql/mysql_create_table.asp
- https://dev.mysql.com/doc/refman/8.4/en/create-table.html
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
- https://www.w3schools.com/sql/sql_insert.asp
- https://learn.microsoft.com/en-us/azure/app-service/configure-language-python#troubleshooting
- https://learn.microsoft.com/en-us/answers/questions/783609/while-hosting-webapp-in-azure-i-am-getting-this-er











