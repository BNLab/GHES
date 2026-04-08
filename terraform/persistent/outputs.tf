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

output "ghes_migration_connection_string" {
  value     = azurerm_storage_account.ghes_migration.primary_connection_string
  sensitive = true
}

output "ghes_static_ip_id" {
  value       = azurerm_public_ip.ghes_static_ip.id
  description = "Resource ID of the static IP — referenced by GHES infra"
}

output "ghes_static_ip_address" {
  value       = azurerm_public_ip.ghes_static_ip.ip_address
  description = "The actual static IP address"
}
