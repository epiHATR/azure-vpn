variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "vpn_gateway_subnet_prefix" {
  type = string
}

variable "vpn_name" {
  type = string
}

variable "vpn_address_prefix" {
  type = string
}

variable "pip_name" {
  type = string
}

variable "pip_allocation_method" {
  type    = string
  default = "Static"
}

variable "pip_sku" {
  type    = string
  default = "Standard"
}

variable "virtual_network_gateway_name" {
  type = string
}

variable "virtual_network_gateway_sku" {
  type    = string
  default = "VpnGw1"
}

variable "vpn_type" {
  type    = string
  default = "RouteBased"
}

variable "virtual_network_gateway_type" {
  type    = string
  default = "Vpn"
}

variable "enable_bgp" {
  type    = bool
  default = false
}

variable "connection_type" {
  type    = string
  default = "IPsec"
}

variable "local_gateways" {
  type = map(
    object({
      name           = string
      address        = string
      address_prefix = string
      shared_key     = string
    })
  )
  default = {
  }
}

variable "subnets" {
  type = map(
    object({
      name           = string
      address_prefix = string
      public         = bool
    })
  )

  default = {
  }
}