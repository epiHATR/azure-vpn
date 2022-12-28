output "gateway_subnet_id" {
  value = azurerm_subnet.gateway_subnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.virtual_network.id
}

output "vnet_name" {
  value = azurerm_virtual_network.virtual_network.name
}

output "vnet_rg" {
  value = azurerm_virtual_network.virtual_network.resource_group_name
}
