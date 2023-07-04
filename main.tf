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

resource "azurerm_storage_account" "sridevstorage2009" {
  name                     = "sridevstorage2009"
  resource_group_name      = "app-grp-sri2009"
  location                 = "East US"
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  depends_on = [ 
    azurerm_resource_group.appgrp
   ]
 
}

resource "azurerm_storage_container" "data" {
  name                  = "sridata"
  storage_account_name  = "sridevstorage2009"
  container_access_type = "blob"
  depends_on = [ 
    azurerm_storage_account.sridevstorage2009
   ]
}

resource "azurerm_storage_blob" "example" {
  name                   = "Jenkinsfile"
  storage_account_name   = "sridevstorage2009"
  storage_container_name = "sridata"
  type                   = "Block"
  source                 = "Jenkinsfile"
  depends_on = [ 
    azurerm_storage_container.data
   ]
}