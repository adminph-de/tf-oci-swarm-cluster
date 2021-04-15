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
variable "image_id" {}
variable "shape" {}

# Integrate a provate OCI Repo (optional)
variable "oci_repo_enable" {}
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
  default = true
  type    = number
}

# Swarm pooled WORKER Node(s)
variable "worker_enabled" {}
variable "worker_node_count" {}
variable "worker_compartment_id" {}
variable "worker_vcn_id" {}
variable "worker_subnet_id" {}
variable "worker_image_id" {}
variable "worker_shape" {}

variable "worker_os_upgrade" {
  default = true
  type    = bool
}
variable "worker_ad" {
  default = true
  type    = number
}

# Swarm OCI Loadbalancer
variable "lb_enable" {}
variable "lb_is_private" {}
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
