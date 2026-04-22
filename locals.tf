locals {
  # Identity block for the DCR resource
  identity = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
    type = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned,UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
    userAssignedIdentities = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      for id in var.managed_identities.user_assigned_resource_ids : id => {}
    } : null
  } : null

  # Role definition resource substring for distinguishing IDs from names
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}

locals {
  # Build the ARM body.properties object from typed variables
  body_properties = {
    agentSettings = var.agent_settings != null ? {
      logs = length(var.agent_settings.logs) > 0 ? [
        for s in var.agent_settings.logs : {
          name  = s.name
          value = s.value
        }
      ] : null
    } : null

    description              = var.description
    dataCollectionEndpointId = var.data_collection_endpoint_id

    dataFlows = length(var.data_flows) > 0 ? [
      for df in var.data_flows : {
        builtInTransform = df.built_in_transform
        captureOverflow  = df.capture_overflow
        destinations     = df.destinations
        outputStream     = df.output_stream
        streams          = df.streams
        transformKql     = df.transform_kql
      }
    ] : null

    dataSources = var.data_sources != null ? {
      dataImports = var.data_sources.data_imports != null ? {
        eventHub = var.data_sources.data_imports.event_hub != null ? {
          consumerGroup = var.data_sources.data_imports.event_hub.consumer_group
          name          = var.data_sources.data_imports.event_hub.name
          stream        = var.data_sources.data_imports.event_hub.stream
        } : null
      } : null

      extensions = length(var.data_sources.extensions) > 0 ? [
        for ext in var.data_sources.extensions : {
          extensionName     = ext.extension_name
          extensionSettings = ext.extension_settings
          inputDataSources  = ext.input_data_sources
          name              = ext.name
          streams           = ext.streams
        }
      ] : null

      iisLogs = length(var.data_sources.iis_logs) > 0 ? [
        for iis in var.data_sources.iis_logs : {
          logDirectories = iis.log_directories
          name           = iis.name
          streams        = iis.streams
          transformKql   = iis.transform_kql
        }
      ] : null

      logFiles = length(var.data_sources.log_files) > 0 ? [
        for lf in var.data_sources.log_files : {
          filePatterns = lf.file_patterns
          format       = lf.format
          name         = lf.name
          settings = lf.settings != null ? {
            text = {
              recordStartTimestampFormat = lf.settings.text.record_start_timestamp_format
            }
          } : null
          streams      = lf.streams
          transformKql = lf.transform_kql
        }
      ] : null

      performanceCounters = length(var.data_sources.performance_counters) > 0 ? [
        for pc in var.data_sources.performance_counters : {
          counterSpecifiers          = pc.counter_specifiers
          name                       = pc.name
          samplingFrequencyInSeconds = pc.sampling_frequency_in_seconds
          streams                    = pc.streams
          transformKql               = pc.transform_kql
        }
      ] : null

      platformTelemetry = length(var.data_sources.platform_telemetry) > 0 ? [
        for pt in var.data_sources.platform_telemetry : {
          name    = pt.name
          streams = pt.streams
        }
      ] : null

      prometheusForwarder = length(var.data_sources.prometheus_forwarder) > 0 ? [
        for pf in var.data_sources.prometheus_forwarder : {
          labelIncludeFilter = pf.label_include_filter
          name               = pf.name
          streams            = pf.streams
        }
      ] : null

      syslog = length(var.data_sources.syslog) > 0 ? [
        for sl in var.data_sources.syslog : {
          facilityNames = sl.facility_names
          logLevels     = sl.log_levels
          name          = sl.name
          streams       = sl.streams
          transformKql  = sl.transform_kql
        }
      ] : null

      windowsEventLogs = length(var.data_sources.windows_event_logs) > 0 ? [
        for wel in var.data_sources.windows_event_logs : {
          name         = wel.name
          streams      = wel.streams
          transformKql = wel.transform_kql
          xPathQueries = wel.x_path_queries
        }
      ] : null

      windowsFirewallLogs = length(var.data_sources.windows_firewall_logs) > 0 ? [
        for wfl in var.data_sources.windows_firewall_logs : {
          name          = wfl.name
          profileFilter = wfl.profile_filter
          streams       = wfl.streams
        }
      ] : null
    } : null

    destinations = var.destinations != null ? {
      azureDataExplorer = length(var.destinations.azure_data_explorer) > 0 ? [
        for adx in var.destinations.azure_data_explorer : {
          databaseName = adx.database_name
          name         = adx.name
          resourceId   = adx.resource_id
        }
      ] : null

      azureMonitorMetrics = var.destinations.azure_monitor_metrics != null ? {
        name = var.destinations.azure_monitor_metrics.name
      } : null

      eventHubs = length(var.destinations.event_hubs) > 0 ? [
        for eh in var.destinations.event_hubs : {
          eventHubResourceId = eh.event_hub_resource_id
          name               = eh.name
        }
      ] : null

      eventHubsDirect = length(var.destinations.event_hubs_direct) > 0 ? [
        for ehd in var.destinations.event_hubs_direct : {
          eventHubResourceId = ehd.event_hub_resource_id
          name               = ehd.name
        }
      ] : null

      logAnalytics = length(var.destinations.log_analytics) > 0 ? [
        for la in var.destinations.log_analytics : {
          name                = la.name
          workspaceResourceId = la.workspace_resource_id
        }
      ] : null

      microsoftFabric = length(var.destinations.microsoft_fabric) > 0 ? [
        for mf in var.destinations.microsoft_fabric : {
          artifactId   = mf.artifact_id
          databaseName = mf.database_name
          ingestionUri = mf.ingestion_uri
          name         = mf.name
          tenantId     = mf.tenant_id
        }
      ] : null

      monitoringAccounts = length(var.destinations.monitoring_accounts) > 0 ? [
        for ma in var.destinations.monitoring_accounts : {
          accountResourceId = ma.account_resource_id
          name              = ma.name
        }
      ] : null

      storageAccounts = length(var.destinations.storage_accounts) > 0 ? [
        for sa in var.destinations.storage_accounts : {
          containerName            = sa.container_name
          name                     = sa.name
          storageAccountResourceId = sa.storage_account_resource_id
        }
      ] : null

      storageBlobsDirect = length(var.destinations.storage_blobs_direct) > 0 ? [
        for sbd in var.destinations.storage_blobs_direct : {
          containerName            = sbd.container_name
          name                     = sbd.name
          storageAccountResourceId = sbd.storage_account_resource_id
        }
      ] : null

      storageTablesDirect = length(var.destinations.storage_tables_direct) > 0 ? [
        for std in var.destinations.storage_tables_direct : {
          name                     = std.name
          storageAccountResourceId = std.storage_account_resource_id
          tableName                = std.table_name
        }
      ] : null
    } : null

    references = var.references != null ? {
      enrichmentData = var.references.enrichment_data != null ? {
        storageBlobs = length(var.references.enrichment_data.storage_blobs) > 0 ? [
          for sb in var.references.enrichment_data.storage_blobs : {
            blobUrl    = sb.blob_url
            lookupType = sb.lookup_type
            name       = sb.name
            resourceId = sb.resource_id
          }
        ] : null
      } : null
    } : null

    streamDeclarations = length(var.stream_declarations) > 0 ? {
      for k, v in var.stream_declarations : k => {
        columns = [
          for col in v.columns : {
            name = col.name
            type = col.type
          }
        ]
      }
    } : null
  }
}
