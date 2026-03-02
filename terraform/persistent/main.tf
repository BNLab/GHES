# ---------------- Resource Group ----------------
resource "azurerm_resource_group" "persistent_rg" {
  name     = "${var.prefix}-persistent-rg"
  location = var.location
  tags     = var.tags
}

# ---------------- Terraform State Storage ----------------
resource "azurerm_storage_account" "tfstate" {
  name                     = var.tfstate_storage_account_name
  resource_group_name      = azurerm_resource_group.persistent_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true  # protects state file history
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

# ---------------- Data Disk ----------------
resource "azurerm_managed_disk" "ghes_data" {
  name                 = "${var.prefix}-ghes-datadisk"
  location             = var.location
  resource_group_name  = azurerm_resource_group.persistent_rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 150
  tags                 = var.tags

  lifecycle {
    prevent_destroy = true
  }
}