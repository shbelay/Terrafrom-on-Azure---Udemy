resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "East US"
}

resource "azurerm_virtual_network" "app_network" {
  name                = local.virtual_network.name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = local.virtual_network.address_prefixes
}

resource "azurerm_network_security_group" "vnetnsg" {
  name                = "vnetSecurityGroup1"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "websubnetnsgassociation" {
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.vnetnsg.id
}

resource "azurerm_subnet_network_security_group_association" "appsubnetnsgassociation" {
  subnet_id                 = azurerm_subnet.appsubnet.id
  network_security_group_id = azurerm_network_security_group.vnetnsg.id
}

resource "azurerm_subnet" "websubnet" {
  name                 = local.subnets[0].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = local.subnets[0].address_prefixes
}

resource "azurerm_network_interface" "webinterface01" {
  name                = "webinterface01"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webpip.id
  }
}

resource "azurerm_network_interface" "webinterface02" {
  name                = "webinterface02"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "webpip" {
  name                = "webPublicIp"
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  allocation_method   = "Static"
}

resource "azurerm_subnet" "appsubnet" {
  name                 = local.subnets[1].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = local.subnets[1].address_prefixes
}

resource "azurerm_storage_account" "appstorage" {
  name                     = "appstoreshbelay"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "SafetyVideo" {
  name                  = "videos"
  storage_account_name  = azurerm_storage_account.appstorage.name
}

resource "azurerm_storage_blob" "MarcosSafetyVideo" {
  name                   = "Marcos-SafetyVideo.mp4"
  storage_account_name   = azurerm_storage_account.appstorage.name
  storage_container_name = "videos"
  type                   = "Block"
  source                 = "Marcos-SafetyVideo.mp4"
}

resource "azurerm_windows_virtual_machine" "webvm01" {
  name                = var.vmName
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  size                = var.vmSize
  admin_username      = var.admin_username
  admin_password      = var.adminPassword
  vm_agent_platform_updates_enabled = true
  network_interface_ids = [
    azurerm_network_interface.webinterface01.id, azurerm_network_interface.webinterface02.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "datadisk01" {
  name                 = "datadisk01"
  location             = local.resource_location
  resource_group_name  = azurerm_resource_group.appgrp.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "4"
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk01_webvm01" {
  managed_disk_id    = azurerm_managed_disk.datadisk01.id
  virtual_machine_id = azurerm_windows_virtual_machine.webvm01.id
  lun                = "0"
  caching            = "ReadWrite"
}