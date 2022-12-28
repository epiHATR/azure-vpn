variable "vpn_rg_name" {
  type = string
}

variable "vpn_rg_location" {
  type = string
}

variable "vpn_name" {
  type = string
}

variable "vpn_address_prefix" {
  type = string
}

variable "vpn_gateway_subnet_prefix" {
  type = string
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

variable "vnet_subnets" {
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
