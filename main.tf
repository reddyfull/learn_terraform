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

module "resource_group" {
  source   = "./resource_group"
  name     = "sriterraformdevenv"
  location = "East US"
}

module "storage_account" {
  source              = "./storage_account"
  name                = "sritfrmstg2019"
  name2               = "sritfrkali2019"
  resource_group_name = module.resource_group.name
  location            = "East US"
}

resource "azurerm_storage_container" "data" {
  name = "data"
  storage_account_name = module.storage_account.name1
  container_access_type = "blob"
  
}

resource "azurerm_storage_blob" "jenkinsfile" {
  name                   = "Jenkinsfile"
  storage_account_name   = module.storage_account.name1
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "/Users/sritadip/Documents/learn_terraform/Jenkinsfile"
}