module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "~> 0.1"

  diagnostic_settings                       = var.diagnostic_settings
  lock                                      = var.lock
  managed_identities                        = var.managed_identities
  role_assignment_definition_lookup_enabled = length(var.role_assignments) > 0
  role_assignment_definition_scope          = var.parent_id
  role_assignments                          = var.role_assignments
}

resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Insights/dataCollectionRules@2024-03-11"
  body = {
    kind = var.kind
    sku = var.sku != null ? {
      capacity = var.sku.capacity
      family   = var.sku.family
      name     = var.sku.name
      size     = var.sku.size
      tier     = var.sku.tier
    } : null
    properties = {
      for k, v in local.body_properties : k => v
      if v != null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "properties.immutableId",
    "properties.provisioningState",
  ]
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = module.avm_interfaces.managed_identities_azapi != null ? [module.avm_interfaces.managed_identities_azapi] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name                   = module.avm_interfaces.lock_azapi.name
  parent_id              = azapi_resource.this.id
  type                   = module.avm_interfaces.lock_azapi.type
  body                   = module.avm_interfaces.lock_azapi.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "diagnostic_setting" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
