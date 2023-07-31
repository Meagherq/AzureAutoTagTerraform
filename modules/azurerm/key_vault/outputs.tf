# output "key_vault_role_assignment_id" {
#     value = module.key_vault_IaC_assignment.id
# }

output "id" {
    value = azurerm_key_vault.kv.id
}