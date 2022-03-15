terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = var.rg_name
  location = var.location
}

resource "azurerm_public_ip" "pip" {
  name = "builder"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name = "default"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name = "DenyAllInbound"
    priority = 2000
    access = "Deny"
    direction = "Inbound"
    protocol = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = "*"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "default" {
  name = "default"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  name = "builder"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "ip0"
    public_ip_address_id = azurerm_public_ip.pip.id
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name = "builder"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  size = var.vm_size
  computer_name = "builder"
  admin_username = var.admin_username
  admin_password = var.admin_password
  enable_automatic_updates = true
  provision_vm_agent = true
  license_type = "Windows_Server"
  network_interface_ids = [ azurerm_network_interface.nic.id ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  boot_diagnostics { }
  
  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-datacenter-azure-edition"
    version = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "auto_shutdown" {
  location = azurerm_resource_group.rg.location
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id

  enabled = true
  daily_recurrence_time = "1900"
  timezone = "Pacific Standard Time"
  notification_settings {
    enabled = false
  }
}

# resource "azurerm_virtual_machine_extension" "configure" {
#   name = "configure"
#   virtual_machine_id = azurerm_windows_virtual_machine.vm.id
#   publisher = "Microsoft.Azure.Extensions"
#   type = "CustomScript"
#   type_handler_version = "2.0"

#   settings = <<SETTINGS
#     {
#       "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("../setup.ps1"), "UTF-16LE")}"
#     } 
# SETTINGS
# }

# TODO: JIT policy (https://github.com/hashicorp/terraform-provider-azurerm/issues/3661)
