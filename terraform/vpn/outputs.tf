output "vnet_id" {
  value = module.vnet.vnet_id
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "vnet_rg" {
  value = module.vnet.vnet_rg
}

output "public_ip_address" {
  value = length(azurerm_public_ip.pip) != 0 ? azurerm_public_ip.pip.0.ip_address : null
}

output "connections" {
  value = azurerm_virtual_network_gateway_connection.lgateway_to_vgateway_connection.*
}