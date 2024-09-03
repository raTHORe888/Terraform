terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "thor-terraform-rg" {
  name     = "thorterraform"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}
resource "azurerm_virtual_network" "thor-terraform-vn" {
  name                = "thor1-network"
  resource_group_name = azurerm_resource_group.thor-terraform-rg.name
  location            = azurerm_resource_group.thor-terraform-rg.location
  address_space       = ["10.171.17.0/24"]
  tags = {
    environment = "dev"
  }
}
resource "azurerm_subnet" "thor-terraform-subnet" {
  name                 = "thor-subnet"
  resource_group_name  = azurerm_resource_group.thor-terraform-rg.name
  virtual_network_name = azurerm_virtual_network.thor-terraform-vn.name
  address_prefixes     = ["10.171.17.16/28"]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
resource "azurerm_netapp_account" "thor-terraform-NA" {
  name                = "thor-Netappaccount"
  location            = azurerm_resource_group.thor-terraform-rg.location
  resource_group_name = azurerm_resource_group.thor-terraform-rg.name
}
resource "azurerm_netapp_pool" "thor-terraform-POOL" {
  name                = "thor-NetApp-pool"
  location            = azurerm_resource_group.thor-terraform-rg.location
  resource_group_name = azurerm_resource_group.thor-terraform-rg.name
  account_name        = azurerm_netapp_account.thor-terraform-NA.name
  service_level       = "Standard"
  size_in_tb          = 4
}
resource "azurerm_netapp_volume" "thor-vol" {
  name                = "thor-vol-netappvolume1"
  location            = azurerm_resource_group.thor-terraform-rg.location
  resource_group_name = azurerm_resource_group.thor-terraform-rg.name
  account_name        = azurerm_netapp_account.thor-terraform-NA.name
  pool_name           = azurerm_netapp_pool.thor-terraform-POOL.name
  volume_path         = "my-unique-file-path"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.thor-terraform-subnet.id
  protocols           = ["NFSv3"]
  storage_quota_in_gb = 100
}










