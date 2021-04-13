variable "loadbalancer_enabled" {
  description = "whether to create the instance"
  default     = false
  type        = bool
}

variable "loadbalancer_compartment_id" {
  description = "whether to create the instance"
  type        = string
}

variable "loadbalancer_name_prefix" {
  description = "a string that will be prepended to all resources"
  type        = string
}

variable "loadbalancer_name_postfix" {
  description = "a string that will be prepended to all resources"
  type        = string
}

variable "loadbalancer_vcn_id" {
  description = "The id of the VCN to use when creating the instance resources."
  type        = string
}

variable "loadbalancer_subnet_id" {
  description = "The id of the subnet to use when creating the instance resources."
  type        = string
}

variable "loadbalancer_shape" {
  description = "The shape of the instance instance."
  default     = "flexible"
  type        = string
}

variable "loadbalancer_hostname_name" {
  description = "The shape of the instance instance."
  type        = string
}

variable "loadbalancer_swarm_backend" {
  description = "The shape of the instance instance."
  type        = string
}

variable "loadbalancer_certificate_name" {
  description = "The shape of the instance instance."
  type        = string
}
variable "loadbalancer_certificate_private_key" {
  description = "The shape of the instance instance."
  type        = string
}
variable "loadbalancer_certificate_public_certificate" {
  description = "The shape of the instance instance."
  type        = string
}
