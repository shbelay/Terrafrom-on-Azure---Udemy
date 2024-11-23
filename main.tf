resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "East US"
}

resource "azurerm_virtual_network" "app_network" {
  name                = local.virtual_network.name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = local.virtual_network.address_prefixes
  
  subnet {
    name             = "websubnet"
    address_prefixes = [local.subnet_address_prefix[0]]
  }

  subnet {
    name             = "appsubnet"
    address_prefixes = [local.subnet_address_prefix[1]]
  }
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