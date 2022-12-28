data "azurerm_resource_group" "vnet_resource_group" {
  name = var.vnet_resource_group
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.vnet_resource_group.location
  resource_group_name = data.azurerm_resource_group.vnet_resource_group.name

  address_space = [var.vnet_address_prefix]

  depends_on = [
    data.azurerm_resource_group.vnet_resource_group
  ]
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = data.azurerm_resource_group.vnet_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.vnet_gateway_subnet_prefix]

  depends_on = [
    azurerm_virtual_network.virtual_network
  ]
}

resource "azurerm_subnet" "additional_subnet" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.vnet_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [each.value.address_prefix]

  depends_on = [
    azurerm_virtual_network.virtual_network
  ]
}

resource "azurerm_network_security_group" "public_nsg" {
  name                = "${var.vnet_name}-public-nsg"
  location            = data.azurerm_resource_group.vnet_resource_group.location
  resource_group_name = data.azurerm_resource_group.vnet_resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_subnet.additional_subnet,
    data.azurerm_resource_group.vnet_resource_group
  ]
}

resource "azurerm_network_security_group" "internal_nsg" {
  name                = "${var.vnet_name}-internal-nsg"
  location            = data.azurerm_resource_group.vnet_resource_group.location
  resource_group_name = data.azurerm_resource_group.vnet_resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "ICMP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_subnet.additional_subnet,
    data.azurerm_resource_group.vnet_resource_group
  ]
}

resource "azurerm_subnet_network_security_group_association" "internal_association" {
  for_each = {
    for k, v in var.subnets : k => v if v.public == false
  }

  network_security_group_id = azurerm_network_security_group.internal_nsg.id
  subnet_id                 = azurerm_subnet.additional_subnet[[for k, v in azurerm_subnet.additional_subnet : k if v.name == each.value.name][0]].id

  depends_on = [
    azurerm_network_security_group.internal_nsg,
    azurerm_subnet.additional_subnet
  ]
}

resource "azurerm_subnet_network_security_group_association" "public_association" {
  for_each = {
    for k, v in var.subnets : k => v if v.public == true
  }

  network_security_group_id = azurerm_network_security_group.public_nsg.id
  subnet_id                 = azurerm_subnet.additional_subnet[[for k, v in azurerm_subnet.additional_subnet : k if v.name == each.value.name][0]].id

  depends_on = [
    azurerm_network_security_group.public_nsg,
    azurerm_subnet.additional_subnet
  ]
}
