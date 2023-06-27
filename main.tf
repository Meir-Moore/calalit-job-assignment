terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatemeir"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "FunctionAppRG"
  location = "eastus"

  tags = {
    environment = "dev"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "vn" {
  name                = "functionapp-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

# Subnet
resource "azurerm_subnet" "sn" {
  name                 = "functionapp-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

# Storage Account
resource "azurerm_storage_account" "st" {
  name                     = "functionappstoragemeir"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# App Service Plan
resource "azurerm_app_service_plan" "svc-plan" {
  name                = "functions-app-svc-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "FunctionApp"

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

# Function App
resource "azurerm_function_app" "function-app" {
  name                       = "functions-app-meir"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.svc-plan.id
  storage_account_name       = azurerm_storage_account.st.name
  storage_account_access_key = azurerm_storage_account.st.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
  }
}

# Data source for Function App
data "azurerm_function_app" "function-app" {
  name                = azurerm_function_app.function-app.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Data source for Subscription
data "azurerm_subscription" "current" {}

# Data source for Role Definition
data "azurerm_role_definition" "func-contributor" {
  name  = "Contributor"
  scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
}

# Role Assignment for Contributor
resource "azurerm_role_assignment" "contributor" {
  scope              = azurerm_storage_account.st.id
  role_definition_id = data.azurerm_role_definition.func-contributor.id
  principal_id       = data.azurerm_function_app.function-app.identity[0].principal_id
}

# Role Assignment for Function App Storage Access
resource "azurerm_role_assignment" "function-app-storage-access" {
  scope                = azurerm_storage_account.st.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_function_app.function-app.identity[0].principal_id
}

# Monitor Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "func-diag" {
  name               = "diag-functions"
  target_resource_id = azurerm_function_app.function-app.id
  storage_account_id = azurerm_storage_account.st.id

  log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

# Private Endpoint for Function App
resource "azurerm_private_endpoint" "function-app-endpoint" {
  name                = "function-app-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sn.id

  private_service_connection {
    name                           = "function-app-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_function_app.function-app.id
    subresource_names              = ["sites"]
  }
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage-endpoint" {
  name                = "storage-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sn.id

  private_service_connection {
    name                           = "storage-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.st.id
    subresource_names              = ["blob"]
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name # Resource Group name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vn.name # Virtual Network name
}

output "subnet_name" {
  value = azurerm_subnet.sn.name # Subnet name
}

output "storage_account_name" {
  value = azurerm_storage_account.st.name # Storage Account name
}

output "app_service_plan_name" {
  value = azurerm_app_service_plan.svc-plan.name # App Service Plan name
}

output "function_app_name" {
  value = azurerm_function_app.function-app.name # Function App name
}

output "role_assignment_contributor_name" {
  value = azurerm_role_assignment.contributor.name # Contributor Role Assignment name
}

output "role_assignment_function_app_storage_access_name" {
  value = azurerm_role_assignment.function-app-storage-access.name # Function App Storage Access Role Assignment name
}

output "private_endpoint_function_app_name" {
  value = azurerm_private_endpoint.function-app-endpoint.name # Function App Private Endpoint name
}

output "private_endpoint_storage_name" {
  value = azurerm_private_endpoint.storage-endpoint.name # Storage Account Private Endpoint name
}
