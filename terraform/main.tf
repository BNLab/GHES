locals {
  rg_name   = "${var.prefix}-rg"
  vnet_name = "${var.prefix}-vnet"
}

# ---------------- Resource Group ----------------
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# ---------------- Network ----------------
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vm_subnet_cidr]
}

# ---------------- Public IP (static) ----------------
resource "azurerm_public_ip" "ghes_pip" {
  name                = "${var.prefix}-ghes-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

# ---------------- NSG ----------------
resource "azurerm_network_security_group" "ghes_nsg" {
  name                = "${var.prefix}-ghes-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["0.0.0.0/0"] # tighten later
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = ["0.0.0.0/0"] # tighten later
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = ["0.0.0.0/0"] # tighten later
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm_subnet_assoc" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.ghes_nsg.id
}

# ---------------- NIC ----------------
resource "azurerm_network_interface" "ghes_nic" {
  name                = "${var.prefix}-ghes-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ghes_pip.id
  }
}

# ---------------- Marketplace agreement (often required) ----------------
resource "azurerm_marketplace_agreement" "ghes" {
  publisher = "GitHub"
  offer     = "GitHub-Enterprise"
  plan      = "GitHub-Enterprise"
}


# ---------------- VM (OS-disk only / no data disk yet) ----------------
resource "azurerm_linux_virtual_machine" "ghes" {
  name                = "${var.prefix}-ghe-server"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.ghes_nic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "${var.prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"

    # keep OS disk disposable when you destroy
    # (default is deletable; included here for clarity)
    # NOTE: azurerm_linux_virtual_machine handles delete with the VM lifecycle.
  }
  
  plan {
    publisher = "GitHub"
    product   = "GitHub-Enterprise"
    name      = "GitHub-Enterprise"
  }

  source_image_reference {
    publisher = "GitHub"
    offer     = "GitHub-Enterprise"
    sku       = "GitHub-Enterprise"
    version   = var.ghes_image_version
  }

  tags = merge(var.tags, {
    role = "github-enterprise-server"
  })

  depends_on = [azurerm_marketplace_agreement.ghes]
}
