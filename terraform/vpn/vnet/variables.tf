variable "vnet_resource_group" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_prefix" {
  type = string
}

variable "vnet_gateway_subnet_prefix" {
  type = string
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