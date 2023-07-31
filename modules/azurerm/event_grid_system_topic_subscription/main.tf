resource "azurerm_eventgrid_system_topic_event_subscription" "sub" {
  name                = var.name
  system_topic        = var.system_topic_name
  resource_group_name = var.resource_group_name

  dynamic "webhook_endpoint" {
    for_each = var.webhook_url != null ? toset([var.webhook_url]) : []
    
    content {
      url = var.webhook_url
    }
  }
}