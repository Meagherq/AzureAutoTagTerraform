data "azurerm_client_config" "current" {}

module "resource_group" {
    source = "../../modules/azurerm/resource_group"

    name = "${var.environment}-autotag-rg"
    location = var.location
}

module "cosmosdb_account" {
    source = "../../modules/azurerm/cosmosdb_account"

    name = "${var.environment}-autotag-cosmosdbacc"
    resource_group_name = module.resource_group.name
    resource_group_location = module.resource_group.location
}

module "cosmosdb_database" {
    source = "../../modules/azurerm/cosmosdb_database"

    name = "AutoTag"
    resource_group_name = module.resource_group.name
    cosmos_db_account_name = module.cosmosdb_account.name
    throughput = "400"
}

module "cosmosdb_container" {
    source = "../../modules/azurerm/cosmosdb_container"

    name = "AutoTag"
    resource_group_name = module.resource_group.name
    cosmos_db_account_name = module.cosmosdb_account.name
    cosmos_db_database_name = module.cosmosdb_database.name
    throughput = "400"
}

module "tagdata_storage_account" {
    source = "../../modules/azurerm/storage_account"

    name = "${var.environment}tagdatasa"
    resource_group_name = module.resource_group.name
    resource_group_location = module.resource_group.location
    key_vault_id = module.autotag_function_app_key_vault.id
    # key_vault_role_assignment_id = module.autotag_function_app_key_vault.key_vault_role_assignment_id
}

module "tagdata_storage_container" {
    source = "../../modules/azurerm/storage_account_container"

    name = "tagdata"
    storage_account_name = module.tagdata_storage_account.name
    container_access_type = "private"
}

module "autotag_app_service_plan" {
    source = "../../modules/azurerm/app_service_plan"

    name = "${var.environment}-autotag-asp"
    sku_name = "S1"
    resource_group_name = module.resource_group.name
    resource_group_location = module.resource_group.location
    os_type = "Linux"
}

module "autotag_function_app" {
    source = "../../modules/azurerm/function_app"

    name = "${var.environment}autotagas"

    app_service_plan_id = module.autotag_app_service_plan.id
    resource_group_name = module.resource_group.name
    resource_group_location = module.resource_group.location

    key_vault_id = module.autotag_function_app_key_vault.id
    # key_vault_role_assignment_id = module.autotag_function_app_key_vault.key_vault_role_assignment_id

    appsettings = {
        "FUNCTIONS_WORKER_RUNTIME" = "python"
        "CosmosDBConnectionString" = module.cosmosdb_account.connection_string
        "BlobStorageConnectionString" = module.tagdata_storage_account.primary_connection_string
        "BLOB_CONNECTION_STRING" = module.tagdata_storage_account.primary_connection_string
        "BLOB_CONTAINER_NAME" = module.tagdata_storage_container.name
        "COSMOS_URL" = module.cosmosdb_account.endpoint
        "COSMOS_KEY" = module.cosmosdb_account.primary_key
        "COSMOS_DATABASE_NAME" = module.cosmosdb_database.name
        "COSMOS_CONTAINER_NAME" = module.cosmosdb_container.name
        "SENDER_EMAIL_ADDRESS" = "placeholder"
        "SENDER_EMAIL_PASSWORD" = "placeholder"
        "RECEIPIENT_EMAIL_ADDRESS" = "placeholder"
        "STMP_SERVER" = "placeholder"
        "SMTP_PORT" = "placeholder"
        "CLIENT_ID" = module.autotag_function_app_identity.app_id
        "CLIENT_SECRET" = module.autotag_function_app_identity.primary_secret
        "TENANT_ID" = data.azurerm_client_config.current.tenant_id
        "AUTHORITY" = "https://login.microsoftonline.com/"
        "SUBSCRIPTION_ID" = data.azurerm_client_config.current.subscription_id
    }
}

module "autotag_function_app_key_vault" {
    source = "../../modules/azurerm/key_vault"

    name = "${var.environment}-autotagkv"

    resource_group_name = module.resource_group.name
    resource_group_location = module.resource_group.location
}

module "tagdata_storage_eventgrid_sub" {
    source = "../../modules/azurerm/event_grid_system_topic_subscription"

    name = "${var.environment}tagdataegsub"
    resource_group_name = module.resource_group.name
    webhook_url = "https://${module.autotag_function_app.hostname}/api/CSVUpload?code="
    system_topic_name = module.tagdata_storage_eventgrid_topic.name
}

module "tagdata_storage_eventgrid_topic" {
    source = "../../modules/azurerm/event_grid_system_topic"

    name = "${var.environment}tagdataegtopic"
    resource_group_name = module.resource_group.name
    location = module.resource_group.location
    source_id = module.tagdata_storage_account.id
    topic_type = "Microsoft.Storage.StorageAccounts"
}

module "rm_subscription_eventgrid_sub" {
    source = "../../modules/azurerm/event_grid_system_topic_subscription"

    name = "${var.environment}autotagegsub"
    resource_group_name = module.resource_group.name
    webhook_url = "https://${module.autotag_function_app.hostname}/api/AutoTagTrigger?code="
    system_topic_name = module.rm_subscription_eventgrid_topic.name
}

module "rm_subscription_eventgrid_topic" {
    source = "../../modules/azurerm/event_grid_system_topic"

    name = "${var.environment}autotagegtopic"
    resource_group_name = module.resource_group.name
    location = module.resource_group.location
    source_id = module.tagdata_storage_account.id
    topic_type = "Microsoft.Resources.Subscriptions"
}

module "autotag_function_app_identity" {
    source = "../../modules/azuread/application_registration"

    display_name = "${var.environment}autotagsp"
    app_identifier = "${var.environment}autotagsp"
}

# module "autotag_function_tag_contributor_assignment" {
#     source = "../../modules/azuread/role_assignment"

#     principal_id = module.autotag_function_app_identity.app_id
#     scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#     role_definition_name = "Tag Contributor"
# }

# module "autotag_function_reader_assignment" {
#     source = "../../modules/azuread/role_assignment"

#     principal_id = module.autotag_function_app_identity.app_id
#     scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#     role_definition_name = "Reader"
# }

# module "autotag_function_key_vault_secrets_user_assignment" {
#     source = "../../modules/azuread/role_assignment"

#     principal_id = module.autotag_function_app.principal_id
#     scope = module.autotag_function_app_key_vault.id
#     role_definition_name = "Key Vault Secrets User"
# }

# module "autotag_function_key_vault_crypto_encryption_user_assignment" {
#     source = "../../modules/azuread/role_assignment"

#     principal_id = module.tagdata_storage_account.id
#     scope = module.autotag_function_app_key_vault.id
#     role_definition_name = "Key Vault Crypto Service Encryption User"
# }

# module "autotag_function_storage_blob_data_contributor_assignment" {
#     source = "../../modules/azuread/role_assignment"

#     principal_id = module.autotag_function_app_identity.app_id
#     scope = module.tagdata_storage_account.id
#     role_definition_name = "Storage Blob Data Contributor"
# }