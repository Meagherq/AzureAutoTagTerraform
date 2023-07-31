resource "azurerm_cosmosdb_account" "db" {
  name                = var.name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.resource_group_location
    failover_priority = 0
  }

  tags = {
    "key" = "value"
    "key2" = "value2"
    "key3" = "value3"
  }

  lifecycle {
    ignore_changes = [ tags["bax-appname"], tags["bax-appid"], tags["bax-owner"], tags["bax-ctime"], tags["bax-creator"] ]
  }
}