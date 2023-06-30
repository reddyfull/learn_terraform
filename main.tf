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
  resource_group_name = module.resource_group.name
  location            = "East US"
}

module "storage_account" {
  source               = "./modules/storage_account"
  name                 = "sritfrmstg2019"
  name2                = "sritfrkali2019"
  resource_group_name  = azurerm_resource_group.sriterraformdevenv.name
  location             = "East US"
}

