data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = var.name
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"
}

# module "key_vault_IaC_assignment" {
#     source = "../../azuread/role_assignment"

#     principal_id = data.azurerm_client_config.current.client_id
#     scope = azurerm_key_vault.kv.id
#     role_definition_name = "Key Vault Administrator"
# }