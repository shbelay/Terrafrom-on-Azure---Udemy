locals {
  resource_location = "East US"
  virtual_network = {
    name = "app-network"
    address_prefixes = ["10.0.0.0/16"]
  }
  subnet_address_prefix = ["10.0.1.0/24","10.0.2.0/24"]
}