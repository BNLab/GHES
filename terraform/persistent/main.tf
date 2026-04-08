# ---------------- Resource Group ----------------
resource "azurerm_resource_group" "persistent_rg" {
  name     = "${var.prefix}-persistent-rg"
  location = var.location
  tags     = var.tags
}

# ---------------- Terraform State Storage ----------------
import {
  to = azurerm_storage_account.tfstate
  id = "/subscriptions/${var.subscription_id}/resourceGroups/tfstate-gov-rg/providers/Microsoft.Storage/storageAccounts/bnlabazuredevworktfstate"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = var.tfstate_storage_account_name
  resource_group_name      = "tfstate-gov-rg"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}


import {
  to = azurerm_storage_container.tfstate
  id = "https://bnlabazuredevworktfstate.blob.core.usgovcloudapi.net/tfstate"
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

# ---------------- GHES Migration Storage ----------------
resource "azurerm_storage_account" "ghes_migration" {
  name                     = "${replace(var.prefix, "-", "")}ghesmigration"
  resource_group_name      = azurerm_resource_group.persistent_rg.name
  location                 = azurerm_resource_group.persistent_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

resource "azurerm_storage_container" "ghes_migration" {
  name                  = "ghes-migration"
  storage_account_name  = azurerm_storage_account.ghes_migration.name
  container_access_type = "private"
}

# Static Public IP — lives in persistent RG
resource "azurerm_public_ip" "ghes_static_ip" {
  name                = "${var.prefix}-ghes-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.persistent_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    prevent_destroy = true
  }