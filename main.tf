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

resource "azurerm_subnet" "websubnet" {
  name                 = local.subnets[0].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = local.subnets[0].address_prefixes
}

resource "azurerm_network_interface" "webinterface" {
  name                = "webinterface"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webpip.id
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