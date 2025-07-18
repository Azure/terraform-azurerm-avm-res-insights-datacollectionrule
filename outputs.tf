output "immutable_id" {
  description = "The immutable ID of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.immutable_id
}

output "location" {
  description = "The location of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.location
}

output "name" {
  description = "The name of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.name
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "This is the full output for the resource."
  value       = azurerm_monitor_data_collection_rule.this
}

output "resource_group_name" {
  description = "The resource group name of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.resource_group_name
}

output "resource_id" {
  description = "The ID of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.id
}

output "system_assigned_mi_principal_id" {
  description = "The principal id of the system managed identity assigned to the virtual machine"
  value       = var.managed_identities.system_assigned == true ? azurerm_monitor_data_collection_rule.this.identity[0].principal_id : null
}
