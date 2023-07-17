variable "name" {}
variable "location" {}

resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location

  lifecycle {
    prevent_destroy = false
  }
}
