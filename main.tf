variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "acr_name" {
  default = "srikali2009"
}
variable "app_name" {
  default = "srikali2009"
}

locals {
  resource_group_name = "srifrontdoor"
  location = "East US"
  virtual_network = {
    name = "sri-network"
    address_space = "10.0.0.0/16"
  }

  subnets=[
    {
      name="subnetA"
      address_prefix="10.0.0.0/24"
    },
    {
      name="subnetB"
      address_prefix="10.0.1.0/24"
    }
  ]
}

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
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "srinetwork" {
  name                = local.virtual_network.name
  location            = local.location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = [local.virtual_network.address_space]
}

resource "azurerm_subnet" "subnetA" {
  name                 = local.subnets[0].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.srinetwork.name
  address_prefixes     = [local.subnets[0].address_prefix]
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.srinetwork.name
  address_prefixes     = [local.subnets[1].address_prefix]
}

resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = local.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.app_name}_service_plan"
  location            = local.location
  resource_group_name = azurerm_resource_group.appgrp.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "app" {
  name                = var.app_name
  location            = local.location
  resource_group_name = azurerm_resource_group.appgrp.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/myapp:latest"
    always_on        = true
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
  }
}
