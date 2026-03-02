output "persistent_rg_name" {
  value = azurerm_resource_group.persistent_rg.name
}

output "tfstate_storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "tfstate_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "ghes_data_disk_id" {
  value = azurerm_managed_disk.ghes_data.id
}