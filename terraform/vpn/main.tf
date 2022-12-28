resource "azurerm_resource_group" "vpn_resource_group" {
  name     = var.rg_name
  location = var.rg_location
}

module "vnet" {
  source = "./vnet"

  vnet_resource_group        = azurerm_resource_group.vpn_resource_group.name
  vnet_gateway_subnet_prefix = var.vpn_gateway_subnet_prefix

  vnet_name           = var.vpn_name
  vnet_address_prefix = var.vpn_address_prefix
  subnets             = var.subnets

  depends_on = [
    azurerm_resource_group.vpn_resource_group
  ]
}

resource "azurerm_public_ip" "pip" {
  count = length(var.local_gateways) != 0 ? 1 : 0

  name                = var.pip_name
  resource_group_name = azurerm_resource_group.vpn_resource_group.name
  location            = azurerm_resource_group.vpn_resource_group.location
  allocation_method   = var.pip_allocation_method
  sku                 = var.pip_sku

  depends_on = [
    azurerm_resource_group.vpn_resource_group
  ]
}

resource "azurerm_virtual_network_gateway" "virtual_network_gateway" {
  count = length(var.local_gateways) != 0 ? 1 : 0

  name                = var.virtual_network_gateway_name
  location            = azurerm_resource_group.vpn_resource_group.location
  resource_group_name = azurerm_resource_group.vpn_resource_group.name

  type     = var.virtual_network_gateway_type
  vpn_type = var.vpn_type

  enable_bgp = var.enable_bgp
  sku        = var.virtual_network_gateway_sku

  ip_configuration {
    name                 = "ngwipconfig"
    public_ip_address_id = azurerm_public_ip.pip.0.id
    subnet_id            = module.vnet.gateway_subnet_id
  }

  depends_on = [
    azurerm_resource_group.vpn_resource_group,
    azurerm_public_ip.pip
  ]
}

resource "azurerm_local_network_gateway" "local_network_gateway" {
  for_each            = var.local_gateways
  resource_group_name = azurerm_resource_group.vpn_resource_group.name
  location            = azurerm_resource_group.vpn_resource_group.location
  name                = each.value.name
  gateway_address     = each.value.address
  address_space       = [each.value.address_prefix]

  depends_on = [
    azurerm_resource_group.vpn_resource_group
  ]
}

resource "azurerm_virtual_network_gateway_connection" "lgateway_to_vgateway_connection" {
  for_each = azurerm_local_network_gateway.local_network_gateway

  name                = "${each.value.name}-connection"
  type                = var.connection_type
  location            = azurerm_resource_group.vpn_resource_group.location
  resource_group_name = azurerm_resource_group.vpn_resource_group.name

  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.0.id
  local_network_gateway_id   = each.value.id
  shared_key                 = var.local_gateways[[for k, v in var.local_gateways : k if v.name == azurerm_local_network_gateway.local_network_gateway[each.key].name][0]].shared_key

  depends_on = [
    azurerm_local_network_gateway.local_network_gateway,
    azurerm_virtual_network_gateway.virtual_network_gateway
  ]
}
