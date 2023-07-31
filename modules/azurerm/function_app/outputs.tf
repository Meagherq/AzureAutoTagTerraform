output "hostname" {
    value = azurerm_linux_function_app.func.default_hostname
}

output "principal_id" {
    value = azurerm_linux_function_app.func.identity.0.principal_id
}

# output "key" {
#     value = data.azurerm_function_app_host_keys.keys.default_function_key
# }