variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

locals {
  resource_group_name = "app-grp-sri2009"
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
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]
}

resource "azurerm_subnet" "subnetA" {
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[0].address_prefix]
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[1].address_prefix]
}

resource "azurerm_storage_account" "funcstorage" {
  name                     = "funcstoragesri2009"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = azurerm_resource_group.appgrp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_app_service_plan" "funcappserviceplan" {
  name                = "func-app-service-plan"
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name

  sku {
    tier = "Dynamic"
    size ="Y1"
  }

  depends_on = [
    azurerm_resource_group.appgrp
  ]
}

resource "azurerm_function_app" "funcapp" {
  name                       = "sriterraformtfstate"
  location                   = azurerm_resource_group.appgrp.location
  resource_group_name        = azurerm_resource_group.appgrp.name
  app_service_plan_id        = azurerm_app_service_plan.funcappserviceplan.id
  storage_account_name       = azurerm_storage_account.funcstorage.name
  storage_account_access_key = azurerm_storage_account.funcstorage.primary_access_key
  os_type                    = "linux"
  version                    = "3.10"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }
}

resource "azurerm_frontdoor" "frontdoor" {
  name                = "example-frontdoor"
  resource_group_name = azurerm_resource_group.appgrp.name
  sku_name            = "Premium_AzureFrontDoor"
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "exampleRoutingRule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["exampleFrontendEndpoint"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "exampleBackendPool"
    }
  }

  backend_pool_load_balancing {
    name = "exampleLoadBalancingSettings"
  }

  backend_pool_health_probe {
    name = "exampleHealthProbeSettings"
  }

  backend_pool {
    name = "exampleBackendPool"
    backend {
      host_header = "www.example.com"
      address     = "www.example.com"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
    }

    load_balancing_name = "exampleLoadBalancingSettings"
    health_probe_name   = "exampleHealthProbeSettings"
  }

  frontend_endpoint {
    name                              = "exampleFrontendEndpoint"
    host_name                         = "example-frontdoor.azurefd.net"
  }
}