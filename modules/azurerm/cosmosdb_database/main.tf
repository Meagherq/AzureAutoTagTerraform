resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.name
  resource_group_name = var.resource_group_name
  account_name        = var.cosmos_db_account_name
  throughput          = var.throughput
}