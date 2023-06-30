# Variables 
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

resource "azurerm_resource_group" "sriterraformdevenv" {
  name     = "sriterraformdevenv"
  location = "East US"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "sritfrmstg2019" {
  name                     = "sritfrmstg2019"
  resource_group_name      = "sriterraformdevenv"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    environment = "developer"
  }

  lifecycle {
    prevent_destroy = true
  }
}


  

