variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

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

resource "azurerm_frontdoor" "example" {
  name                                         = "srifrontdoor"
  resource_group_name                          = "srifrontdoor"
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "srifrontdoor/webroute"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["srikali122009"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "testweh"
    }
  }

  backend_pool_load_balancing {
    name = "loadBalancingSettings"
    sample_size            = 4
    successful_samples_required = 3
    additional_latency_milliseconds = 50
  }

  backend_pool_health_probe {
    name = "healthProbeSettings"
    path = "/"
    protocol = "Http"
    probe_method = "HEAD"
    interval_in_seconds = 100
  }

  backend_pool {
    name = "testweh"
    backend {
      host_header = "cs21003200290ace8b6.blob.core.windows.net"
      address     = "cs21003200290ace8b6.blob.core.windows.net"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "loadBalancingSettings"
    health_probe_name   = "healthProbeSettings"
  }
}

resource "azurerm_frontdoor_firewall_policy" "example" {
  name                = "srifrontdoor"
  resource_group_name = "srifrontdoor"
  mode                = "Detection"
  
  custom_rule {
    name      = "Microsoft_DefaultRuleSet"
    enabled   = true
    priority  = 1
    rule_type = "MatchRule"
    
    match_conditions {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
    }

    action = "Block"
  }

  managed_rule {
    type    = "DefaultRuleSet"
    version = "2.1"
    rule_group_override {
      rule_group_name = "PHP"
      rules {
        rule_id = "933111"
        enabled = false
        action  = "Block"
      }
    }
  }
}