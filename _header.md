# terraform-azurerm-avm-res-insights-datacollectionrule

This module deploys an Azure Monitor Data Collection Rule (DCR) using the AzAPI provider.

Data Collection Rules define how Azure Monitor collects and routes monitoring data. They specify data sources (performance counters, Windows Event Logs, Syslog, custom logs, etc.), destinations (Log Analytics workspaces, Azure Monitor Metrics, Event Hubs, Storage Accounts, etc.), and data flows that connect sources to destinations with optional KQL transformations.

## Features

- Full support for all data source types (performance counters, Windows Event Logs, Syslog, extensions, log files, IIS logs, platform telemetry, Prometheus forwarder, Windows Firewall logs)
- All destination types (Log Analytics, Azure Monitor Metrics, Event Hubs, Storage Accounts, Azure Data Explorer, Microsoft Fabric, monitoring accounts)
- Custom stream declarations
- KQL transformations in data flows
- Managed identity support (system-assigned and user-assigned)
- Resource locks and role assignments
- Diagnostic settings
- AVM telemetry
