terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
}

data "azurerm_subscription" "sub" {
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "builder_rg" {
  name = var.builder_rg_name
  location = var.location
}

resource "azurerm_resource_group" "images_rg" {
  name = var.images_rg_name
  location = var.location
}

# TODO: JIT policy (https://github.com/hashicorp/terraform-provider-azurerm/issues/3661)
