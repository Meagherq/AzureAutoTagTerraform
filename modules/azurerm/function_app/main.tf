resource "azurerm_linux_function_app" "func" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  storage_account_name       = module.func_storage_account.name
  storage_account_access_key = module.func_storage_account.primary_key
  service_plan_id            = var.app_service_plan_id

  app_settings = merge(var.appsettings, { "APPINSIGHTS_INSTRUMENTATIONKEY" = module.func_app_insights.instrumentation_key })

  identity {
    type = "SystemAssigned"
  }

  site_config {}
}

module "func_storage_account" {
  source = "../storage_account"

  name = "${var.name}sa"
  resource_group_location = var.resource_group_location
  resource_group_name = var.resource_group_name
  key_vault_id = var.key_vault_id
  # key_vault_role_assignment_id = var.key_vault_role_assignment_id
}

module "func_app_insights" {
  source = "../application_insights"

  resource_group_name = var.resource_group_name
  name = "${var.name}ai"
  resource_group_location = var.resource_group_location
  application_type = "other"
}

# data "azurerm_function_app_host_keys" "keys" {
#   name                = azurerm_linux_function_app.func.name
#   resource_group_name = azurerm_linux_function_app.func.resource_group_name
# }

