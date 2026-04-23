terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}

resource "random_pet" "name" {
  length = 2
}

# Create a resource group
resource "azapi_resource" "resource_group" {
  location               = "eastus"
  name                   = "rg-${random_pet.name.id}"
  type                   = "Microsoft.Resources/resourceGroups@2024-03-01"
  body                   = {}
  response_export_values = []
}

# Create a Log Analytics workspace as a destination
resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "law-${random_pet.name.id}"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      sku = {
        name = "PerGB2018"
      }
      retentionInDays = 30
    }
  }
  response_export_values = []
}

# This is the module call
module "test" {
  source = "../../"

  location                   = azapi_resource.resource_group.location
  name                       = "dcr-${random_pet.name.id}"
  resource_group_resource_id = azapi_resource.resource_group.id
  data_flows = [
    {
      destinations = ["law-dest"]
      streams      = ["Microsoft-Perf"]
    }
  ]
  data_sources = {
    performance_counters = [
      {
        name                          = "perfcounter-datasource"
        counter_specifiers            = ["\\Processor(_Total)\\% Processor Time", "\\Memory\\Available Bytes"]
        sampling_frequency_in_seconds = 60
        streams                       = ["Microsoft-Perf"]
      }
    ]
  }
  destinations = {
    log_analytics = [
      {
        name                  = "law-dest"
        workspace_resource_id = azapi_resource.log_analytics_workspace.id
      }
    ]
  }
  enable_telemetry = var.enable_telemetry
  kind             = "Windows"
}
