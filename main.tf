variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

terraform {
  required_version = ">= 0.14.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.63.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret

  features {}
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp-sri2009"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "sri-network"
  location            = "East US"
  resource_group_name = "app-grp-sri2009"
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.example.id
  }
 

  tags = {
    environment = "Developer"
  }
   depends_on = [ 
    azurerm_resource_group.appgrp
   ]
}