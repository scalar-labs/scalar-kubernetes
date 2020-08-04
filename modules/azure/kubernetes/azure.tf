terraform {
  required_version = ">= 0.12.20"
}

provider "azurerm" {
  version = ">= 2.21.0"
  features {}
}

provider "azuread" {
  version = ">= 0.11.0"
}
