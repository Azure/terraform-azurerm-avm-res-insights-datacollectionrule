<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.115, < 5.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.7)

## Resources

The following resources are used by this module:

- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_data_collection_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_data_flows"></a> [data\_flows](#input\_data\_flows)

Description: A list of data flow configurations that define how data moves from sources to destinations.
- `streams` - (Required) A list of streams to be sent to the destinations
- `destinations` - (Required) A list of destination names where the data will be sent
- `built_in_transform` - (Optional) The built-in transform to transform stream data
- `output_stream` - (Optional) The output stream of the transform. Only required if the data flow changes data to a different stream
- `transform_kql` - (Optional) The KQL query to transform stream data

Type:

```hcl
list(object({
    streams            = list(string)
    destinations       = list(string)
    built_in_transform = optional(string, null)
    output_stream      = optional(string, null)
    transform_kql      = optional(string, null)
  }))
```

### <a name="input_destinations"></a> [destinations](#input\_destinations)

Description: The destinations block which defines where the data will be sent. At least one destination must be specified.
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

Type:

```hcl
object({
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
```

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key)

Description: A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.

Type:

```hcl
object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
```

Default: `null`

### <a name="input_data_collection_endpoint_id"></a> [data\_collection\_endpoint\_id](#input\_data\_collection\_endpoint\_id)

Description: (Optional) The resource ID of the Data Collection Endpoint that this rule can be used with.

Type: `string`

Default: `null`

### <a name="input_data_sources"></a> [data\_sources](#input\_data\_sources)

Description: The data sources configuration block. This is optional and can be omitted if the rule is meant to be used via direct calls to the provisioned endpoint.
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

Type:

```hcl
object({
    data_import = optional(object({
      event_hub_data_source = object({
        name           = string
        stream         = string
        consumer_group = optional(string, null)
      })
    }), null)
    extension = optional(list(object({
      extension_name     = string
      name               = string
      streams            = list(string)
      extension_json     = optional(string, null)
      input_data_sources = optional(list(string), [])
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
```

Default: `{}`

### <a name="input_description"></a> [description](#input\_description)

Description: (Optional) The description of the Data Collection Rule.

Type: `string`

Default: `null`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_kind"></a> [kind](#input\_kind)

Description: (Optional) The kind of the Data Collection Rule. Possible values are Linux, Windows, AgentDirectToStore and WorkspaceTransforms. A rule of kind Linux does not allow for windows\_event\_log data sources. And a rule of kind Windows does not allow for syslog data sources. If kind is not specified, all kinds of data sources are allowed. Note: Once kind has been set, changing it forces a new Data Collection Rule to be created.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Note: `system_assigned` and `user_assigned_resource_ids` cannot be used together. Only one type of managed identity is allowed.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_stream_declarations"></a> [stream\_declarations](#input\_stream\_declarations)

Description: A list of stream declarations for custom streams. Each stream declaration must have a unique stream\_name that begins with 'Custom-'.
- `stream_name` - (Required) The name of the custom stream, must begin with 'Custom-'
- `columns` - (Required) List of column definitions with name and type (string, int, long, real, boolean, datetime, dynamic)

Type:

```hcl
list(object({
    stream_name = string
    columns = list(object({
      name = string
      type = string
    }))
  }))
```

Default: `[]`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_immutable_id"></a> [immutable\_id](#output\_immutable\_id)

Description: The immutable ID of the Data Collection Rule.

### <a name="output_location"></a> [location](#output\_location)

Description: The location of the Data Collection Rule.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Data Collection Rule.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name)

Description: The resource group name of the Data Collection Rule.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the Data Collection Rule.

### <a name="output_system_assigned_mi_principal_id"></a> [system\_assigned\_mi\_principal\_id](#output\_system\_assigned\_mi\_principal\_id)

Description: The principal id of the system managed identity assigned to the virtual machine

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->