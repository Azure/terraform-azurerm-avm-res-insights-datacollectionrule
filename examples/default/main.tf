terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115, < 5.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = "dcr-test"
  resource_group_name = azurerm_resource_group.this.name

  destinations = {
    azure_monitor_metrics = {
      this = {
        name = "azureMonitorMetrics-default"
      }
    }
  }

  data_sources = {
    performance_counter = [
      {
        name                          = "perfCounterDataSource60"
        sampling_frequency_in_seconds = 60
        counter_specifiers = [
          "\\System\\System Up Time"
        ]
        streams = [
          "Microsoft-InsightsMetrics"
        ]
      }
    ]
  }

  data_flows = [
    {
      destinations = ["azureMonitorMetrics-default"]
      streams      = ["Microsoft-InsightsMetrics"]
    }
  ]
}
