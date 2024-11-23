terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.10.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id = ""
  client_secret = ""
  tenant_id = ""
  subscription_id = ""
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "East US"
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