# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "bitroid-k8s" {
  name     = "bitroid-k8s-resources"
  location = "westus"
}

# Create virtual network
resource "azurerm_virtual_network" "bitroid-k8s" {
  name                = "acctvnbitroid-k8s"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.bitroid-k8s.location
  resource_group_name = azurerm_resource_group.bitroid-k8s.name
}

# Create subnet
resource "azurerm_subnet" "bitroid-k8s" {
  name                 = "acctsubbitroid-k8s"
  resource_group_name  = azurerm_resource_group.bitroid-k8s.name
  virtual_network_name = azurerm_virtual_network.bitroid-k8s.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IP Address
resource "azurerm_public_ip" "bitroid-k8s" {
  name                = "publicipbitroid-k8s"
  location            = azurerm_resource_group.bitroid-k8s.location
  resource_group_name = azurerm_resource_group.bitroid-k8s.name
  allocation_method   = "Static"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "bitroid-k8s" {
  name                = "nsgbitroid-k8s"
  location            = azurerm_resource_group.bitroid-k8s.location
  resource_group_name = azurerm_resource_group.bitroid-k8s.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create virtual network interface
resource "azurerm_network_interface" "bitroid-k8s" {
  name                = "acctnibitroid-k8s"
  location            = azurerm_resource_group.bitroid-k8s.location
  resource_group_name = azurerm_resource_group.bitroid-k8s.name

  ip_configuration {
    name                          = "testconfiguration1bitroid-k8s"
    subnet_id                     = azurerm_subnet.bitroid-k8s.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bitroid-k8s.id
  }
}

# Create a Linux virtual machine

resource "azurerm_virtual_machine" "bitroid-k8s" {
  name                  = "acctvmbitroid-k8s"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  location              = azurerm_resource_group.bitroid-k8s.location
  resource_group_name   = azurerm_resource_group.bitroid-k8s.name
  network_interface_ids = [azurerm_network_interface.bitroid-k8s.id]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.7"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    caching       = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "master-bitroid-k8s"
    admin_username = "azurebitra"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "bitroid-k8s" {
  name                 = "master-bitroid-k8s"
  virtual_machine_id   = azurerm_virtual_machine.bitroid-k8s.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "echo jenkins"
    }
SETTINGS


  tags = {
    environment = "Production"
  }
}

output "ip" {
  value = azurerm_public_ip.bitroid-k8s.ip_address
}