terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.34.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azure_vpn" {
  source = "./vpn"

  rg_name                      = var.vpn_rg_name
  rg_location                  = var.vpn_rg_location
  vpn_name                     = var.vpn_name
  vpn_address_prefix           = var.vpn_address_prefix
  vpn_gateway_subnet_prefix    = var.vpn_gateway_subnet_prefix
  pip_name                     = "${var.vpn_name}-pip"
  virtual_network_gateway_name = "${var.vpn_name}-vgateway"
  local_gateways               = var.local_gateways
  subnets                      = var.vnet_subnets
}
