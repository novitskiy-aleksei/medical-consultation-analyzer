terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "medical-consultation-analyzer"
  location = "West Europe"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "mcafiles"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "audio_container" {
  name                  = "audio-container"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "text_container" {
  name                  = "text-container"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}
