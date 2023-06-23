provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "DeveloperResourcesri2023Group"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "developertfstoragesro2023"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
