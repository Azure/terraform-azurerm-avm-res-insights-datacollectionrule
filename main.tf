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
