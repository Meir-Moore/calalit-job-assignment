# Terraform Azure Function App Deployment

**Disclaimer: This project is for educational purposes only.**

This project demonstrates the deployment of an Azure Function App using Terraform. It provisions necessary Azure resources, including a resource group, virtual network, subnet, storage account, app service plan, function app, private endpoints, and role assignments.


## Prerequisites

To run this project, ensure that you have the following prerequisites installed:

- Terraform (version 1.0.0 or later)
- Azure CLI
- Azure subscription and credentials

## Getting Started

 Clone this repository to your local machine:

1. ```shell
   git clone https://github.com/your-username/terraform-azure-function-app.git

2. ```shell
   cd terraform-azure-function-app

3. ```shell
     terraform init
   
4. ```shell
   az login

5. ```shell
   az account set --subscription <subscription_id>

6. ```shell
   terraform plan

7. ```shell
   terraform apply
7. ```shell
   terraform destroy

