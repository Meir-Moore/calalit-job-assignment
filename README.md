# Terraform Azure Function App Deployment

**Disclaimer: This project is for educational purposes only.**

This project demonstrates the deployment of an Azure Function App using Terraform. It provisions necessary Azure resources, including a resource group, virtual network, subnet, storage account, app service plan, function app, private endpoints, and role assignments.


## Prerequisites

To run this project, ensure that you have the following prerequisites installed:

- Terraform (version 3.0.0 or later)
- Azure CLI
- Azure subscription and credentials
- Create a resource group and storage account for saving the terraform state file in azue:
$RESOURCE_GROUP_NAME='tfstate'
$STORAGE_ACCOUNT_NAME="tfstate$(Get-Random)"
$CONTAINER_NAME='tfstate'

# Create resource group
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location eastus

# Create storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME -SkuName Standard_LRS -Location eastus -AllowBlobPublicAccess $false

# Create blob container
New-AzStorageContainer -Name $CONTAINER_NAME -Context $storageAccount.context****

## Getting Started

 Clone this repository to your local machine:

1. ```shell
     cd terraform-azure-function-app
2. ```shell
     terraform init
3. ```shell
     az login
4. ```shell
     az account set --subscription <subscription_id>
5. ```shell
     terraform plan
6. ```shell
     terraform apply
7. ```shell
     terraform destroy

