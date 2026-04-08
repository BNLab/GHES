output "ghes_public_ip" {
  value = data.azurerm_public_ip.ghes_pip.ip_address
}

output "ghes_url_hint" {
  value = "https://${data.azurerm_public_ip.ghes_pip.ip_address}/"
}
