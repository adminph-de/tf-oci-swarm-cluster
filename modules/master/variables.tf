# ---------------------------------------------------------------------------------------------------------------------
# MISC
# ---------------------------------------------------------------------------------------------------------------------
variable "instance_tenancy_ocid" {
  type = string
}
variable "instance_label_prefix" {
  description = "a string that will be prepended to all resources"
  type        = string
  default     = "node"
}

variable "instance_label_postfix" {
  description = "a string that will be prepended to all resources"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# GENERATE INSTANCE: instance
# ---------------------------------------------------------------------------------------------------------------------

variable "instance_enabled" {
  description = "whether to create the instance"
  default     = false
  type        = bool
}

variable "instance_region" {
  description = "The OCI region to use when creating the instance resources."
  type        = string
}

variable "instance_compartment_id" {
  description = "The id of the compartmnet to use when creating the instance resources."
  type        = string
}

variable "instance_availability_domain" {
  description = "the AD to place the instance host"
  default     = 1
  type        = number
}

variable "instance_vcn_id" {
  description = "The id of the VCN to use when creating the instance resources."
  type        = string
}

variable "instance_subnet_id" {
  description = "The id of the subnet to use when creating the instance resources."
  type        = string
}

variable "instance_image_id" {
  description = "Provide a custom image id for the instance host or leave as Autonomous."
  default     = "Oracle"
  type        = string
}

variable "instance_shape" {
  description = "The shape of the instance instance."
  default = {
    shape = "VM.Standard.E3.Flex", ocpus = 1, memory = 4, boot_volume_size = 50
  }
  type = map(any)
}

variable "instance_upgrade" {
  description = "Whether to upgrade the instance host packages after provisioning. It's useful to set this to false during development/testing so the instance is provisioned faster."
  default     = false
  type        = bool
}

variable "instance_ssh_public_key" {
  description = "the content of the ssh public key used to access the instance. set this or the instance_ssh_public_key_path"
  default     = ""
  type        = string
}

variable "instance_ssh_public_key_path" {
  description = "path to the ssh public key used to access the instance. set this or the instance_ssh_public_key"
  default     = ""
  type        = string
}

variable "instance_timezone" {
  description = "The preferred timezone for the instance host."
  default     = "Australia/Sydney"
  type        = string
}

variable "instance_template_script" {
  description = "Customization Script for the Instance"
  default     = "none"
  type        = string
}

variable "instance_cloud_init_file" {
  description = "Customization CloudInit Script for the Instance"
  default     = "none"
  type        = string
}

variable "instance_operating_system" {
  description = "Customize Operationg System for the Instance"
  default     = "Oracle Linux"
  type        = string
}

variable "instance_operating_system_version" {
  description = "Customize Operationg System version for the Instance"
  default     = "7.9"
  type        = string
}

variable "instance_swarm_worker_count" {
  description = "Count of Workers in the Swarm Cluster"
  default     = 0
}

variable "instance_swarm_master_ip" {
  description = "The IP addess of a depending host if necessary for the cloud-init script."
  default     = "0.0.0.0"
  type        = string
}



variable "swarm_oci_repo_enable" {
  description = "Configure OCI repo"
  default     = false
  type        = bool
}

variable "swarm_oci_repo_server" {
  description = "Name of the OCI Repo Server"
  default     = "none"
  type        = string
}
variable "swarm_oci_repo_username" {
  description = "Username to access the Repo"
  default     = "none"
  type        = string
}
variable "swarm_oci_repo_auth_secret" {
  description = "Username's secret (plain) to access the Repo"
  default     = "none"
  type        = string
}
variable "swarm_oci_repo_auth_secret_encypted" {
  description = "Username's secret (encrypted) to access the Repo"
  default     = "none"
  type        = string
}

variable "swarm_oci_swarm_fqdn" {
  description = "The URL (fqdn) where you can access the Traefic Dashboard."
  default     = "oci-traefik.mydomain.com"
  type        = string
}

variable "swarm_traefik_enabled" {
  description = "Deploy a Swarm Traefik Proxy."
  default     = false
  type        = bool
}
variable "swarm_traefik_dashboard_login" {
  description = "Username/Password Compination to access the Traefik Dashboard (default is set to: admin:admin)"
  default     = "admin:$$apr1$$dcTFTl3L$$bZ4qzYwV0t5rB/1IdoCWa/"
  type        = string
}

variable "swarm_portainer_enabled" {
  description = "Deploy a Portainer env."
  default     = false
  type        = bool
}
