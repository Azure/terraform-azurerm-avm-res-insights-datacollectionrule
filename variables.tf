variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name))
    error_message = "The name must contain between 1 to 64 characters inclusive. The name only allows alphanumeric characters, underscores, hyphens and cannot start or end in a space."
  }
}

variable "kind" {
  type        = string
  default     = null
  description = "(Optional) The kind of the Data Collection Rule. Possible values are Linux, Windows, AgentDirectToStore and WorkspaceTransforms. A rule of kind Linux does not allow for windows_event_log data sources. And a rule of kind Windows does not allow for syslog data sources. If kind is not specified, all kinds of data sources are allowed. Note: Once kind has been set, changing it forces a new Data Collection Rule to be created."

  validation {
    condition     = var.kind == null ? true : contains(["Linux", "Windows", "AgentDirectToStore", "WorkspaceTransforms"], var.kind)
    error_message = "The kind must be one of: 'Linux', 'Windows', 'AgentDirectToStore', or 'WorkspaceTransforms'."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) The description of the Data Collection Rule."
}

variable "data_collection_endpoint_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of the Data Collection Endpoint that this rule can be used with."
}

variable "destinations" {
  type = object({
    azure_monitor_metrics = optional(list(object({
      name = string
    })), [])
    event_hub = optional(list(object({
      event_hub_id = string
      name         = string
    })), [])
    event_hub_direct = optional(list(object({
      event_hub_id = string
      name         = string
    })), [])
    log_analytics = optional(list(object({
      workspace_resource_id = string
      name                  = string
    })), [])
    monitor_account = optional(list(object({
      monitor_account_id = string
      name               = string
    })), [])
    storage_blob = optional(list(object({
      storage_account_id = string
      container_name     = string
      name               = string
    })), [])
    storage_blob_direct = optional(list(object({
      storage_account_id = string
      container_name     = string
      name               = string
    })), [])
    storage_table_direct = optional(list(object({
      storage_account_id = string
      table_name         = string
      name               = string
    })), [])
  })
  description = <<DESCRIPTION
The destinations block which defines where the data will be sent. At least one destination must be specified.
- `azure_monitor_metrics` - (Optional) A list of Azure Monitor Metrics destinations
  - `name` - (Required) The name of the destination
- `event_hub` - (Optional) A list of Event Hub destinations
  - `event_hub_id` - (Required) The resource ID of the Event Hub
  - `name` - (Required) The name of the destination
- `event_hub_direct` - (Optional) A list of Event Hub Direct destinations (only available for AgentDirectToStore kind)
  - `event_hub_id` - (Required) The resource ID of the Event Hub
  - `name` - (Required) The name of the destination
- `log_analytics` - (Optional) A list of Log Analytics destinations
  - `workspace_resource_id` - (Required) The resource ID of the Log Analytics workspace
  - `name` - (Required) The name of the destination
- `monitor_account` - (Optional) A list of Monitor Account destinations
  - `monitor_account_id` - (Required) The resource ID of the Monitor Account
  - `name` - (Required) The name of the destination
- `storage_blob` - (Optional) A list of Storage Blob destinations
  - `storage_account_id` - (Required) The resource ID of the Storage Account
  - `container_name` - (Required) The name of the container
  - `name` - (Required) The name of the destination
- `storage_blob_direct` - (Optional) A list of Storage Blob Direct destinations (only available for AgentDirectToStore kind)
  - `storage_account_id` - (Required) The resource ID of the Storage Account
  - `container_name` - (Required) The name of the container
  - `name` - (Required) The name of the destination
- `storage_table_direct` - (Optional) A list of Storage Table Direct destinations (only available for AgentDirectToStore kind)
  - `storage_account_id` - (Required) The resource ID of the Storage Account
  - `table_name` - (Required) The name of the table
  - `name` - (Required) The name of the destination
DESCRIPTION

  validation {
    condition = (
      length(var.destinations.azure_monitor_metrics) > 0 ||
      length(var.destinations.event_hub) > 0 ||
      length(var.destinations.event_hub_direct) > 0 ||
      length(var.destinations.log_analytics) > 0 ||
      length(var.destinations.monitor_account) > 0 ||
      length(var.destinations.storage_blob) > 0 ||
      length(var.destinations.storage_blob_direct) > 0 ||
      length(var.destinations.storage_table_direct) > 0
    )
    error_message = "At least one destination must be specified."
  }
}

variable "data_flows" {
  type = list(object({
    streams           = list(string)
    destinations      = list(string)
    built_in_transform = optional(string, null)
    output_stream     = optional(string, null)
    transform_kql     = optional(string, null)
  }))
  description = <<DESCRIPTION
A list of data flow configurations that define how data moves from sources to destinations.
- `streams` - (Required) A list of streams to be sent to the destinations
- `destinations` - (Required) A list of destination names where the data will be sent
- `built_in_transform` - (Optional) The built-in transform to transform stream data
- `output_stream` - (Optional) The output stream of the transform. Only required if the data flow changes data to a different stream
- `transform_kql` - (Optional) The KQL query to transform stream data
DESCRIPTION
}

variable "data_sources" {
  type = object({
    data_import = optional(object({
      event_hub_data_source = object({
        name           = string
        stream         = string
        consumer_group = optional(string, null)
      })
    }), null)
    extension = optional(list(object({
      extension_name      = string
      name                = string
      streams             = list(string)
      extension_json      = optional(string, null)
      input_data_sources  = optional(list(string), [])
    })), [])
    iis_log = optional(list(object({
      name            = string
      streams         = list(string)
      log_directories = optional(list(string), [])
    })), [])
    log_file = optional(list(object({
      name          = string
      streams       = list(string)
      file_patterns = list(string)
      format        = string
      settings = optional(object({
        text = object({
          record_start_timestamp_format = string
        })
      }), null)
    })), [])
    performance_counter = optional(list(object({
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
      name    = string
      streams = list(string)
      label_include_filter = optional(list(object({
        label = string
        value = string
      })), [])
    })), [])
    syslog = optional(list(object({
      facility_names = list(string)
      streams        = list(string)
      log_levels     = list(string)
      name           = string
    })), [])
    windows_event_log = optional(list(object({
      name           = string
      streams        = list(string)
      x_path_queries = list(string)
    })), [])
    windows_firewall_log = optional(list(object({
      name    = string
      streams = list(string)
    })), [])
  })
  default     = {}
  description = <<DESCRIPTION
The data sources configuration block. This is optional and can be omitted if the rule is meant to be used via direct calls to the provisioned endpoint.
- `data_import` - (Optional) Data import configuration for Event Hub data sources
  - `event_hub_data_source` - (Required) Configuration for Event Hub data source
    - `name` - (Required) The name of the Event Hub data source
    - `stream` - (Required) The stream name to use for the data source
    - `consumer_group` - (Optional) The consumer group to use for the Event Hub
- `extension` - (Optional) List of VM extension data sources
  - `extension_name` - (Required) The name of the VM extension
  - `name` - (Required) The name of the data source
  - `streams` - (Required) List of streams to send data to
  - `extension_json` - (Optional) JSON configuration for the extension
  - `input_data_sources` - (Optional) List of input data sources
- `iis_log` - (Optional) List of IIS log data sources
  - `name` - (Required) The name of the data source
  - `streams` - (Required) List of streams to send data to
  - `log_directories` - (Optional) List of log directories to monitor
- `log_file` - (Optional) List of log file data sources
  - `name` - (Required) The name of the data source
  - `streams` - (Required) List of streams to send data to
  - `file_patterns` - (Required) List of file patterns to match
  - `format` - (Required) The format of the log file (e.g., "text")
  - `settings` - (Optional) Additional settings for the log file
    - `text` - (Required) Text format settings
      - `record_start_timestamp_format` - (Required) Timestamp format for record start
- `performance_counter` - (Optional) List of performance counter data sources
  - `counter_specifiers` - (Required) List of performance counter specifiers
  - `name` - (Required) The name of the data source
  - `sampling_frequency_in_seconds` - (Required) Sampling frequency in seconds
  - `streams` - (Required) List of streams to send data to
- `platform_telemetry` - (Optional) List of platform telemetry data sources
  - `name` - (Required) The name of the data source
  - `streams` - (Required) List of streams to send data to
- `prometheus_forwarder` - (Optional) List of Prometheus forwarder data sources
  - `name` - (Required) The name of the data source
  - `streams` - (Required) List of streams to send data to
  - `label_include_filter` - (Optional) List of label filters to include
    - `label` - (Required) The label name to filter on
    - `value` - (Required) The label value to filter on
- `syslog` - (Optional) List of syslog data sources
  - `facility_names` - (Required) List of syslog facility names
  - `streams` - (Required) List of streams to send data to
  - `log_levels` - (Required) List of log levels to capture
  - `name` - (Required) The name of the data source
- `windows_event_log` - (Optional) List of Windows event log data sources
  - `name` - (Required) The name of the data source
  - `streams` - (Required) List of streams to send data to
  - `x_path_queries` - (Required) List of XPath queries to filter events
- `windows_firewall_log` - (Optional) List of Windows firewall log data sources
  - `name` - (Required) The name of the data source
  - `streams` - (Required) List of streams to send data to
DESCRIPTION
}

variable "stream_declarations" {
  type = list(object({
    stream_name = string
    columns = list(object({
      name = string
      type = string
    }))
  }))
  default     = []
  description = <<DESCRIPTION
A list of stream declarations for custom streams. Each stream declaration must have a unique stream_name that begins with 'Custom-'.
- `stream_name` - (Required) The name of the custom stream, must begin with 'Custom-'
- `columns` - (Required) List of column definitions with name and type (string, int, long, real, boolean, datetime, dynamic)
DESCRIPTION

  validation {
    condition = alltrue([
      for stream in var.stream_declarations : 
      can(regex("^Custom-", stream.stream_name))
    ])
    error_message = "All stream names must begin with 'Custom-'."
  }

  validation {
    condition = alltrue([
      for stream in var.stream_declarations : 
      alltrue([
        for column in stream.columns :
        contains(["string", "int", "long", "real", "boolean", "datetime", "dynamic"], column.type)
      ])
    ])
    error_message = "Column types must be one of: string, int, long, real, boolean, datetime, dynamic."
  }
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
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
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
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

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
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

Note: `system_assigned` and `user_assigned_resource_ids` cannot be used together. Only one type of managed identity is allowed.
DESCRIPTION
  nullable    = false

  validation {
    condition     = !(var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0)
    error_message = "Cannot use both system_assigned and user_assigned_resource_ids together. Only one type of managed identity is allowed."
  }
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
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
