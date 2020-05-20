terraform {
  required_version = ">= 0.12.20"
}

provider "azurerm" {
  version = ">=2.5.0"
  features {}
}

provider "azuread" {
  version = ">= 0.8"
}
