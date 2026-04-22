# --- DCR-specific variables ---

# --- AVM interface variables ---

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the data collection rule."
  nullable    = false
}

variable "resource_group_resource_id" {
  type        = string
  description = "The resource ID of the resource group in which to create the data collection rule."
  nullable    = false
}

variable "agent_settings" {
  type = object({
    logs = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  default     = null
  description = <<DESCRIPTION
Agent settings used to modify agent behavior on a given host.

- `logs` - (Optional) All the settings that are applicable to the logs agent (AMA).
  - `name` - (Required) The name of the setting. Supported values: `MaxDiskQuotaInMB`, `UseTimeReceivedForForwardedEvents`.
  - `value` - (Required) The value of the setting.
DESCRIPTION
}

variable "data_collection_endpoint_id" {
  type        = string
  default     = null
  description = "The resource ID of the data collection endpoint that this rule can be used with."
}

variable "data_flows" {
  type = list(object({
    built_in_transform = optional(string, null)
    capture_overflow   = optional(bool, null)
    destinations       = list(string)
    output_stream      = optional(string, null)
    streams            = list(string)
    transform_kql      = optional(string, null)
  }))
  default     = []
  description = <<DESCRIPTION
The specification of data flows for the data collection rule.

- `built_in_transform` - (Optional) The built-in transform to transform stream data.
- `capture_overflow` - (Optional) Flag to enable overflow column in Log Analytics destinations.
- `destinations` - (Required) List of destination names for this data flow.
- `output_stream` - (Optional) The output stream of the transform. Only required if the transform changes data to a different stream.
- `streams` - (Required) List of streams for this data flow.
- `transform_kql` - (Optional) The KQL query to transform stream data.
DESCRIPTION
  nullable    = false
}

variable "data_sources" {
  type = object({
    data_imports = optional(object({
      event_hub = optional(object({
        consumer_group = optional(string, null)
        name           = string
        stream         = optional(string, null)
      }), null)
    }), null)
    extensions = optional(list(object({
      extension_name     = string
      extension_settings = optional(any, null)
      input_data_sources = optional(list(string), null)
      name               = string
      streams            = list(string)
    })), [])
    etw_providers = optional(list(object({
      event_ids     = optional(list(string), null)
      keyword       = optional(string, null)
      log_level     = optional(string, null)
      name          = string
      provider      = string
      provider_type = string
      streams       = list(string)
    })), [])
    iis_logs = optional(list(object({
      log_directories = optional(list(string), null)
      name            = string
      streams         = list(string)
      transform_kql   = optional(string, null)
    })), [])
    log_files = optional(list(object({
      file_patterns = list(string)
      format        = string
      name          = string
      settings = optional(object({
        text = object({
          record_start_timestamp_format = string
        })
      }), null)
      streams       = list(string)
      transform_kql = optional(string, null)
    })), [])
    otel_logs = optional(list(object({
      enrich_with_reference              = optional(string, null)
      enrich_with_resource_attributes    = optional(list(string), null)
      name                               = string
      replace_resource_id_with_reference = optional(bool, null)
      resource_attribute_routing = optional(object({
        attribute_name  = optional(string, null)
        attribute_value = optional(string, null)
      }), null)
      streams = list(string)
    })), [])
    otel_metrics = optional(list(object({
      enrich_with_reference           = optional(string, null)
      enrich_with_resource_attributes = optional(list(string), null)
      name                            = string
      resource_attribute_routing = optional(object({
        attribute_name  = optional(string, null)
        attribute_value = optional(string, null)
      }), null)
      streams = list(string)
    })), [])
    otel_traces = optional(list(object({
      enrich_with_reference              = optional(string, null)
      enrich_with_resource_attributes    = optional(list(string), null)
      name                               = string
      replace_resource_id_with_reference = optional(bool, null)
      resource_attribute_routing = optional(object({
        attribute_name  = optional(string, null)
        attribute_value = optional(string, null)
      }), null)
      streams = list(string)
    })), [])
    performance_counters = optional(list(object({
      counter_specifiers            = list(string)
      name                          = string
      sampling_frequency_in_seconds = number
      streams                       = list(string)
      transform_kql                 = optional(string, null)
    })), [])
    performance_counters_otel = optional(list(object({
      counter_specifiers            = list(string)
      name                          = string
      sampling_frequency_in_seconds = number
      streams                       = list(string)
    })), [])
    platform_telemetry = optional(list(object({
      name    = string
      streams = list(string)
    })), [])
    prometheus_forwarder = optional(list(object({
      custom_vm_scrape_config = optional(list(any), null)
      label_include_filter    = optional(map(string), null)
      name                    = string
      streams                 = list(string)
    })), [])
    syslog = optional(list(object({
      facility_names = list(string)
      log_levels     = list(string)
      name           = string
      streams        = list(string)
      transform_kql  = optional(string, null)
    })), [])
    windows_event_logs = optional(list(object({
      name           = string
      streams        = list(string)
      transform_kql  = optional(string, null)
      x_path_queries = list(string)
    })), [])
    windows_firewall_logs = optional(list(object({
      name           = string
      profile_filter = optional(list(string), null)
      streams        = list(string)
    })), [])
  })
  default     = null
  description = <<DESCRIPTION
The specification of data sources for the data collection rule. This property is optional and can be omitted if the rule is meant to be used via direct calls to the provisioned endpoint.

- `data_imports` - (Optional) Specifications of pull based data sources.
  - `event_hub` - (Optional) Event Hub data import configuration.
- `extensions` - (Optional) The list of Azure VM extension data source configurations.
- `etw_providers` - (Optional) The list of ETW provider data source configurations.
- `iis_logs` - (Optional) The list of IIS logs source configurations.
- `log_files` - (Optional) The list of log files source configurations.
- `otel_logs` - (Optional) The list of OpenTelemetry logs data source configurations.
- `otel_metrics` - (Optional) The list of OpenTelemetry metrics data source configurations.
- `otel_traces` - (Optional) The list of OpenTelemetry traces data source configurations.
- `performance_counters` - (Optional) The list of performance counter data source configurations.
- `performance_counters_otel` - (Optional) The list of OpenTelemetry performance counter data source configurations.
- `platform_telemetry` - (Optional) The list of platform telemetry configurations.
- `prometheus_forwarder` - (Optional) The list of Prometheus forwarder data source configurations.
- `syslog` - (Optional) The list of Syslog data source configurations.
- `windows_event_logs` - (Optional) The list of Windows Event Log data source configurations.
- `windows_firewall_logs` - (Optional) The list of Windows Firewall logs source configurations.
DESCRIPTION
}

variable "description" {
  type        = string
  default     = null
  description = "A description of the data collection rule."
}

variable "destinations" {
  type = object({
    azure_data_explorer = optional(list(object({
      database_name = string
      name          = string
      resource_id   = string
    })), [])
    azure_monitor_metrics = optional(object({
      name = string
    }), null)
    event_hubs = optional(list(object({
      event_hub_resource_id = string
      name                  = string
    })), [])
    event_hubs_direct = optional(list(object({
      event_hub_resource_id = string
      name                  = string
    })), [])
    log_analytics = optional(list(object({
      name                  = string
      workspace_resource_id = string
    })), [])
    microsoft_fabric = optional(list(object({
      artifact_id   = string
      database_name = string
      ingestion_uri = string
      name          = string
      tenant_id     = optional(string, null)
    })), [])
    monitoring_accounts = optional(list(object({
      account_resource_id = string
      name                = string
    })), [])
    storage_accounts = optional(list(object({
      container_name              = string
      name                        = string
      storage_account_resource_id = string
    })), [])
    storage_blobs_direct = optional(list(object({
      container_name              = string
      name                        = string
      storage_account_resource_id = string
    })), [])
    storage_tables_direct = optional(list(object({
      name                        = string
      storage_account_resource_id = string
      table_name                  = string
    })), [])
  })
  default     = null
  description = <<DESCRIPTION
The specification of destinations for the data collection rule.

- `azure_data_explorer` - (Optional) List of Azure Data Explorer destinations.
- `azure_monitor_metrics` - (Optional) Azure Monitor Metrics destination.
- `event_hubs` - (Optional) List of Event Hubs destinations.
- `event_hubs_direct` - (Optional) List of Event Hubs Direct destinations.
- `log_analytics` - (Optional) List of Log Analytics destinations.
- `microsoft_fabric` - (Optional) List of Microsoft Fabric destinations.
- `monitoring_accounts` - (Optional) List of monitoring account destinations.
- `storage_accounts` - (Optional) List of storage accounts destinations.
- `storage_blobs_direct` - (Optional) List of Storage Blob Direct destinations.
- `storage_tables_direct` - (Optional) List of Storage Table Direct destinations.
DESCRIPTION
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the data collection rule. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "direct_data_sources" {
  type = object({
    otel_logs = optional(list(object({
      enrich_with_reference              = optional(string, null)
      enrich_with_resource_attributes    = optional(list(string), null)
      name                               = string
      replace_resource_id_with_reference = optional(bool, null)
      streams                            = list(string)
    })), [])
    otel_metrics = optional(list(object({
      enrich_with_reference           = optional(string, null)
      enrich_with_resource_attributes = optional(list(string), null)
      name                            = string
      streams                         = list(string)
    })), [])
    otel_traces = optional(list(object({
      enrich_with_reference              = optional(string, null)
      enrich_with_resource_attributes    = optional(list(string), null)
      name                               = string
      replace_resource_id_with_reference = optional(bool, null)
      streams                            = list(string)
    })), [])
  })
  default     = null
  description = <<DESCRIPTION
The specification of direct data sources. This property is optional and can be omitted.

- `otel_logs` - (Optional) The list of OpenTelemetry logs direct data source configurations.
- `otel_metrics` - (Optional) The list of OpenTelemetry metrics direct data source configurations.
- `otel_traces` - (Optional) The list of OpenTelemetry traces direct data source configurations.
DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "kind" {
  type        = string
  default     = null
  description = "The kind of the data collection rule. Possible values are `Linux` and `Windows`."

  validation {
    condition     = var.kind == null || contains(["Linux", "Windows"], var.kind)
    error_message = "The kind must be one of: 'Linux', 'Windows', or null."
  }
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `"CanNotDelete"` and `"ReadOnly"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "references" {
  type = object({
    application_insights = optional(list(object({
      name        = string
      resource_id = string
    })), [])
    enrichment_data = optional(object({
      storage_blobs = optional(list(object({
        blob_url    = string
        lookup_type = string
        name        = string
        resource_id = string
      })), [])
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
Defines all the references that may be used in other sections of the DCR.

- `application_insights` - (Optional) Application Insights references to be used on OTel metrics/logs enrichment.
  - `name` - (Required) The name of the reference used as an alias when referencing this application insights in OTel data sources.
  - `resource_id` - (Required) ID of the Application Insights resource.
- `enrichment_data` - (Optional) All the enrichment data sources referenced in data flows.
  - `storage_blobs` - (Optional) All the storage blobs used as enrichment data sources.
    - `blob_url` - (Required) URL of the storage blob.
    - `lookup_type` - (Required) The type of lookup to perform on the blob. Possible values: `Cidr`, `String`.
    - `name` - (Required) The name of the enrichment data source used as an alias when referencing in data flows.
    - `resource_id` - (Required) Resource ID of the storage account that hosts the blob.
DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "sku" {
  type = object({
    capacity = optional(number, null)
    family   = optional(string, null)
    name     = string
    size     = optional(string, null)
    tier     = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
The SKU of the data collection rule resource.

- `capacity` - (Optional) If the SKU supports scale out/in then the capacity integer should be included.
- `family` - (Optional) If the service has different generations of hardware, for the same SKU, then that can be captured here.
- `name` - (Required) The name of the SKU. E.g. P3. It is typically a letter+number code.
- `size` - (Optional) The SKU size.
- `tier` - (Optional) This field is required to be implemented by the Resource Provider if the service has more than one tier. Possible values: `Basic`, `Free`, `Premium`, `Standard`.
DESCRIPTION

  validation {
    condition     = var.sku == null || var.sku.tier == null || contains(["Basic", "Free", "Premium", "Standard"], var.sku.tier)
    error_message = "The SKU tier must be one of: 'Basic', 'Free', 'Premium', 'Standard', or null."
  }
}

variable "stream_declarations" {
  type = map(object({
    columns = list(object({
      name = string
      type = string
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
Declaration of custom streams used in this rule. The map key is the stream name (e.g., "Custom-MyStream").

- `columns` - (Required) List of column definitions for the custom stream.
  - `name` - (Required) The name of the column.
  - `type` - (Required) The type of the column data. Possible values are `boolean`, `datetime`, `dynamic`, `int`, `long`, `real`, `string`.
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
