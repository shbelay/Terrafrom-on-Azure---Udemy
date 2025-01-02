resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

//Virtual Network
resource "azurerm_virtual_network" "app_network" {
  name                = local.virtual_network.name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = local.virtual_network.address_prefixes
}

//Subnet
resource "azurerm_subnet" "app_network_subnets" {
  for_each = {
    websubnet = ["10.0.0.0/24"]
    appsubnet = ["10.0.1.0/24"]
  }
  name                 = each.key
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = each.value
}

//Network Interface in Web Subnet
resource "azurerm_network_interface" "webinterfaces" {
  count = var.azurerm_network_interface_count
  name = "webinterface0${count.index}"
  location = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.app_network_subnets["websubnet"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webip[count.index].id
  }
}

//Public IP
resource "azurerm_public_ip" "webip" {
  count = var.azurerm_network_interface_count
  name = "webip0${count.index}"
  resource_group_name = azurerm_resource_group.appgrp.name
  location = local.resource_location
  allocation_method = "Static"  
}