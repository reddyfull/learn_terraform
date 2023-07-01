output "name1" {
  description = "The name of the first storage account"
  value       = azurerm_storage_account.sa.name
}

output "name2" {
  description = "The name of the second storage account"
  value       = azurerm_storage_account.sa2.name
}


