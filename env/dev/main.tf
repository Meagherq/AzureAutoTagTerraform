terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.43.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.33.0"
    }
  }
}

# Configure the default provider
provider "azurerm" {
    features {}
}

provider "azuread" {}

#data
data "azurerm_client_config" "current" {}

module "autotag" {
    source = "../../project/AutoTag"

    environment = var.environment
    location = var.location
}