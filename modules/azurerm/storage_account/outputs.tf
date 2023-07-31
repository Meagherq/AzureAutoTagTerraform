output "name" {
    value = azurerm_storage_account.sa.name
}

output "primary_connection_string" {
    value = azurerm_storage_account.sa.primary_blob_connection_string
}

output "primary_key" {
    value = azurerm_storage_account.sa.primary_access_key
}

output "id" {
    value = azurerm_storage_account.sa.id
}