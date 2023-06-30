variable "name" {}
variable "name2" {}
variable "resource_group_name" {}
variable "location" {}

resource "azurerm_storage_account" "sa" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    environment = "developer"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_account" "sa2" {
  name                     = var.name2
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    environment = "developer"
  }

  lifecycle {
    prevent_destroy = false
  }
}
