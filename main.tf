resource "azurerm_monitor_data_collection_rule" "this" {
  location                    = var.location
  name                        = var.name
  resource_group_name         = var.resource_group_name
  data_collection_endpoint_id = var.data_collection_endpoint_id
  description                 = var.description
  kind                        = var.kind
  tags                        = var.tags

  dynamic "data_flow" {
    for_each = var.data_flows

    content {
      destinations       = data_flow.value.destinations
      streams            = data_flow.value.streams
      built_in_transform = data_flow.value.built_in_transform
      output_stream      = data_flow.value.output_stream
      transform_kql      = data_flow.value.transform_kql
    }
  }
  destinations {
    dynamic "azure_monitor_metrics" {
      for_each = var.destinations.azure_monitor_metrics

      content {
        name = azure_monitor_metrics.value.name
      }
    }
    dynamic "event_hub" {
      for_each = var.destinations.event_hub

      content {
        event_hub_id = event_hub.value.event_hub_id
        name         = event_hub.value.name
      }
    }
    dynamic "event_hub_direct" {
      for_each = var.destinations.event_hub_direct

      content {
        event_hub_id = event_hub_direct.value.event_hub_id
        name         = event_hub_direct.value.name
      }
    }
    dynamic "log_analytics" {
      for_each = var.destinations.log_analytics

      content {
        name                  = log_analytics.value.name
        workspace_resource_id = log_analytics.value.workspace_resource_id
      }
    }
    dynamic "monitor_account" {
      for_each = var.destinations.monitor_account

      content {
        monitor_account_id = monitor_account.value.monitor_account_id
        name               = monitor_account.value.name
      }
    }
    dynamic "storage_blob" {
      for_each = var.destinations.storage_blob

      content {
        container_name     = storage_blob.value.container_name
        name               = storage_blob.value.name
        storage_account_id = storage_blob.value.storage_account_id
      }
    }
    dynamic "storage_blob_direct" {
      for_each = var.destinations.storage_blob_direct

      content {
        container_name     = storage_blob_direct.value.container_name
        name               = storage_blob_direct.value.name
        storage_account_id = storage_blob_direct.value.storage_account_id
      }
    }
    dynamic "storage_table_direct" {
      for_each = var.destinations.storage_table_direct

      content {
        name               = storage_table_direct.value.name
        storage_account_id = storage_table_direct.value.storage_account_id
        table_name         = storage_table_direct.value.table_name
      }
    }
  }
  dynamic "data_sources" {
    for_each = var.data_sources != null ? [var.data_sources] : []

    content {
      dynamic "data_import" {
        for_each = data_sources.value.data_import != null ? [data_sources.value.data_import] : []

        content {
          event_hub_data_source {
            name           = data_import.value.event_hub_data_source.name
            stream         = data_import.value.event_hub_data_source.stream
            consumer_group = data_import.value.event_hub_data_source.consumer_group
          }
        }
      }
      dynamic "extension" {
        for_each = data_sources.value.extension

        content {
          extension_name     = extension.value.extension_name
          name               = extension.value.name
          streams            = extension.value.streams
          extension_json     = extension.value.extension_json
          input_data_sources = extension.value.input_data_sources
        }
      }
      dynamic "iis_log" {
        for_each = data_sources.value.iis_log

        content {
          name            = iis_log.value.name
          streams         = iis_log.value.streams
          log_directories = iis_log.value.log_directories
        }
      }
      dynamic "log_file" {
        for_each = data_sources.value.log_file

        content {
          file_patterns = log_file.value.file_patterns
          format        = log_file.value.format
          name          = log_file.value.name
          streams       = log_file.value.streams

          dynamic "settings" {
            for_each = log_file.value.settings != null ? [log_file.value.settings] : []

            content {
              text {
                record_start_timestamp_format = settings.value.text.record_start_timestamp_format
              }
            }
          }
        }
      }
      dynamic "performance_counter" {
        for_each = data_sources.value.performance_counter

        content {
          counter_specifiers            = performance_counter.value.counter_specifiers
          name                          = performance_counter.value.name
          sampling_frequency_in_seconds = performance_counter.value.sampling_frequency_in_seconds
          streams                       = performance_counter.value.streams
        }
      }
      dynamic "platform_telemetry" {
        for_each = data_sources.value.platform_telemetry

        content {
          name    = platform_telemetry.value.name
          streams = platform_telemetry.value.streams
        }
      }
      dynamic "prometheus_forwarder" {
        for_each = data_sources.value.prometheus_forwarder

        content {
          name    = prometheus_forwarder.value.name
          streams = prometheus_forwarder.value.streams

          dynamic "label_include_filter" {
            for_each = prometheus_forwarder.value.label_include_filter

            content {
              label = label_include_filter.value.label
              value = label_include_filter.value.value
            }
          }
        }
      }
      dynamic "syslog" {
        for_each = data_sources.value.syslog

        content {
          facility_names = syslog.value.facility_names
          log_levels     = syslog.value.log_levels
          name           = syslog.value.name
          streams        = syslog.value.streams
        }
      }
      dynamic "windows_event_log" {
        for_each = data_sources.value.windows_event_log

        content {
          name           = windows_event_log.value.name
          streams        = windows_event_log.value.streams
          x_path_queries = windows_event_log.value.x_path_queries
        }
      }
      dynamic "windows_firewall_log" {
        for_each = data_sources.value.windows_firewall_log

        content {
          name    = windows_firewall_log.value.name
          streams = windows_firewall_log.value.streams
        }
      }
    }
  }
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  dynamic "stream_declaration" {
    for_each = var.stream_declarations

    content {
      stream_name = stream_declaration.value.stream_name

      dynamic "column" {
        for_each = stream_declaration.value.columns

        content {
          name = column.value.name
          type = column.value.type
        }
      }
    }
  }
}

# required AVM resources interfaces

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = azurerm_monitor_data_collection_rule.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}

# Management Lock
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_monitor_data_collection_rule.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_monitor_data_collection_rule.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
