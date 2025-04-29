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




