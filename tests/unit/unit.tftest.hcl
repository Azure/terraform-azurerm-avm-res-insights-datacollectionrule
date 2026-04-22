mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/dataCollectionRules/test-dcr"
      name     = "test-dcr"
      location = "eastus"
      output   = {}
    }
  }

  mock_data "azapi_client_config" {
    defaults = {
      subscription_id          = "00000000-0000-0000-0000-000000000000"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
      tenant_id                = "00000000-0000-0000-0000-000000000001"
    }
  }
}
mock_provider "modtm" {
  mock_data "modtm_module_source" {
    defaults = {
      module_source  = "registry.terraform.io/Azure/avm-res-insights-datacollectionrule/azurerm"
      module_version = "0.1.0"
    }
  }
}
mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  location                   = "eastus"
  name                       = "test-dcr"
  resource_group_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  enable_telemetry           = true

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
        counter_specifiers            = ["\\Processor(_Total)\\% Processor Time"]
        sampling_frequency_in_seconds = 60
        streams                       = ["Microsoft-Perf"]
      }
    ]
  }

  destinations = {
    log_analytics = [
      {
        name                  = "law-dest"
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
      }
    ]
  }

  kind = "Windows"
}

run "basic_dcr_creation" {
  command = apply

  assert {
    condition     = azapi_resource.this.name == "test-dcr"
    error_message = "DCR name should be 'test-dcr'."
  }

  assert {
    condition     = azapi_resource.this.location == "eastus"
    error_message = "DCR location should be 'eastus'."
  }

  assert {
    condition     = output.name == "test-dcr"
    error_message = "Output name should be 'test-dcr'."
  }

  assert {
    condition     = output.resource_id != ""
    error_message = "Output resource_id should not be empty."
  }
}

run "telemetry_enabled_by_default" {
  command = apply

  assert {
    condition     = length(modtm_telemetry.telemetry) == 1
    error_message = "Telemetry resource should be created when enable_telemetry is true (default)."
  }
}

run "telemetry_disabled" {
  command = apply

  variables {
    enable_telemetry = false
  }

  assert {
    condition     = length(modtm_telemetry.telemetry) == 0
    error_message = "Telemetry resource should not be created when enable_telemetry is false."
  }
}

run "lock_creation" {
  command = apply

  variables {
    lock = {
      kind = "CanNotDelete"
      name = "test-lock"
    }
  }

  assert {
    condition     = length(azapi_resource.lock) == 1
    error_message = "Lock resource should be created when lock is specified."
  }

  assert {
    condition     = azapi_resource.lock[0].name == "test-lock"
    error_message = "Lock name should be 'test-lock'."
  }
}

run "no_lock_by_default" {
  command = apply

  assert {
    condition     = length(azapi_resource.lock) == 0
    error_message = "Lock resource should not be created when lock is null."
  }
}

run "minimal_dcr_no_data_sources" {
  command = apply

  variables {
    data_sources = null
    data_flows   = []
    destinations = null
    kind         = null
  }

  assert {
    condition     = azapi_resource.this.name == "test-dcr"
    error_message = "Minimal DCR should be created successfully."
  }
}
