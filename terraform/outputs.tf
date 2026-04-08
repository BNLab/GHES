output "ghes_public_ip" {
  value = azurerm_public_ip.ghes_pip.ip_address
}

output "ghes_url_hint" {
  value = "https://${azurerm_public_ip.ghes_pip.ip_address}/"
}
