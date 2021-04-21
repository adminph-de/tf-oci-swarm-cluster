# Oracle Cloud Access Settings
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

# Defaults
variable "label_prefix" {}
variable "label_postfix" {}
variable "ssh_public_key" {}
variable "ssh_public_key_path" {}
variable "timezone" {}
variable "compartment_id" {}
variable "vcn_id" {}
variable "subnet_id" {}
variable "image_id" {
  type        = string
  default     = "Oracle"
  description = "Default is set to Oracle Linux."
}
variable "instance_shape" {
  type = object({
    shape            = string
    ocpus            = number
    memory           = number
    boot_volume_size = number
  })
  default = {
    shape            = "VM.Standard.E3.Flex",
    ocpus            = 2,
    memory           = 12,
    boot_volume_size = 50
  }
  description = "Instance Shape as FLEX image (recommended). In case of non FLEX, don't set the ocpus and memory and use the shape name only."
}

# Integrate a provate OCI Repo (optional)
variable "oci_repo_enable" {
  default = true
  type    = bool
}
variable "oci_repo_server" {}
variable "oci_repo_username" {}
variable "oci_repo_auth_secret" {}
variable "oci_repo_auth_secret_encypted" {}

# Swarm MASTER Node
variable "master_compartment_id" {}
variable "master_vcn_id" {}
variable "master_subnet_id" {}
variable "master_image_id" {}
variable "master_shape" {}

variable "master_os_upgrade" {
  default = true
  type    = bool
}
variable "master_ad" {
  default = 1
  type    = number
}

# Swarm pooled WORKER Node(s)
variable "worker_map" {}

# Swarm OCI Loadbalancer
variable "lb_enable" {
  default = true
  type    = bool
}
variable "lb_is_private" {
  default = true
  type    = bool
}
variable "lb_compartment_id" {}
variable "lb_vcn_id" {}
variable "lb_subnet_id" {}
variable "lb_shape" {}
variable "lb_host_name" {}
variable "lb_certificate_name" {}
variable "lb_ca_certificate" {}
variable "lb_passphrase" {}
variable "lb_certificate_private_key" {}
variable "lb_public_certificate" {}


variable "traefik_enabled" {
  description = "Deploy a Swarm Traefik Proxy."
  default     = false
  type        = bool
}
variable "traefik_dashboard_fqdn" {
  description = "FQDN of the Traefik Dashboard"
  default     = "my-dashboard.domain.com"
  type        = string
}
variable "traefik_dashboard_login" {
  description = "Username/Password Compination to access the Traefik Dashboard (default is set to: admin:admin)"
  default     = "admin:$$apr1$$dcTFTl3L$$bZ4qzYwV0t5rB/1IdoCWa/"
  type        = string
}

variable "portainer_enabled" {
  description = "Deploy a Portainer env."
  default     = false
  type        = bool
}
variable "portainer_fqdn" {
  description = "FQDN of the Portainer Service"
  default     = "my-portainer.domain.com"
  type        = string

}
variable "portainer_edge_fqdn" {
  description = "FQDN of the Portainer EDGE Service"
  default     = "my-portainer-edge.domain.com"
  type        = string

}
