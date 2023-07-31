output "name" {
    value = azurerm_cosmosdb_account.db.name
}

output "endpoint" {
    value = azurerm_cosmosdb_account.db.endpoint
}

output "primary_key" {
    value = azurerm_cosmosdb_account.db.primary_key
}

output "connection_string" {
    value = "AccountEndpoint=${azurerm_cosmosdb_account.db.endpoint};AccountKey=${azurerm_cosmosdb_account.db.primary_key};"
}