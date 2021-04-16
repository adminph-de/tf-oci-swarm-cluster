module "master" {
  source = "./modules/master"

  instance_enabled                    = true
  instance_tenancy_ocid               = var.tenancy_ocid
  instance_region                     = var.region
  instance_label_prefix               = var.label_prefix
  instance_label_postfix              = var.label_postfix
  instance_compartment_id             = var.master_compartment_id != "" ? var.master_compartment_id : var.compartment_id
  instance_availability_domain        = var.master_ad
  instance_vcn_id                     = var.master_vcn_id != "" ? var.master_vcn_id : var.vcn_id
  instance_subnet_id                  = var.master_subnet_id != "" ? var.master_subnet_id : var.subnet_id
  instance_image_id                   = var.master_image_id != "" ? var.master_image_id : var.image_id
  instance_shape                      = var.master_shape != {} ? var.master_shape : var.instance_shape
  instance_upgrade                    = var.master_os_upgrade
  instance_ssh_public_key             = var.ssh_public_key
  instance_ssh_public_key_path        = var.ssh_public_key_path
  instance_timezone                   = var.timezone
  swarm_oci_repo_enable               = var.oci_repo_enable
  swarm_oci_repo_server               = var.oci_repo_server
  swarm_oci_repo_username             = var.oci_repo_username
  swarm_oci_repo_auth_secret          = var.oci_repo_auth_secret
  swarm_oci_repo_auth_secret_encypted = var.oci_repo_auth_secret_encypted
  swarm_oci_fqdn_portainer            = var.lb_host_name
}

module "worker" {
  source = "./modules/worker"

  for_each = var.worker_map

  instance_enabled                    = each.value.enabled
  instance_tenancy_ocid               = var.tenancy_ocid
  instance_region                     = each.value.region != "" ? each.value.region : var.region
  instance_swarm_worker_count         = each.value.node_count
  instance_swarm_master_ip            = module.master.instance_private_ip
  instance_label_prefix               = var.label_prefix
  instance_label_postfix              = "${each.key}-${var.label_postfix}"
  instance_compartment_id             = each.value.compartment_id != "" ? each.value.compartment_id : var.compartment_id
  instance_availability_domain        = each.value.ad
  instance_vcn_id                     = each.value.vcn_id != "" ? each.value.vcn_id : var.vcn_id
  instance_subnet_id                  = each.value.subnet_id != "" ? each.value.subnet_id : var.subnet_id
  instance_image_id                   = each.value.image_id != "" ? each.value.image_id : var.image_id
  instance_shape                      = each.value.worker_shape != {} ? each.value.worker_shape : var.instance_shape
  instance_upgrade                    = each.value.os_upgrade
  instance_ssh_public_key             = var.ssh_public_key
  instance_ssh_public_key_path        = var.ssh_public_key_path
  instance_timezone                   = var.timezone
  swarm_oci_repo_enable               = var.oci_repo_enable
  swarm_oci_repo_server               = var.oci_repo_server
  swarm_oci_repo_username             = var.oci_repo_username
  swarm_oci_repo_auth_secret          = var.oci_repo_auth_secret
  swarm_oci_repo_auth_secret_encypted = var.oci_repo_auth_secret_encypted
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  loadbalancer_enabled                 = var.lb_enable
  loadbalancer_is_private              = var.lb_is_private
  loadbalancer_compartment_id          = var.lb_compartment_id != "" ? var.lb_compartment_id : var.compartment_id
  loadbalancer_name_prefix             = var.label_prefix
  loadbalancer_name_postfix            = var.label_postfix
  loadbalancer_vcn_id                  = var.lb_vcn_id != "" ? var.lb_vcn_id : var.vcn_id
  loadbalancer_subnet_id               = var.lb_subnet_id != "" ? var.lb_subnet_id : var.subnet_id
  loadbalancer_shape                   = var.lb_shape
  loadbalancer_hostname_name           = var.lb_host_name
  loadbalancer_swarm_backend           = module.master.instance_private_ip
  loadbalancer_certificate_name        = var.lb_certificate_name
  loadbalancer_passphrase              = var.lb_passphrase
  loadbalancer_ca_certificate          = file(var.lb_ca_certificate)
  loadbalancer_certificate_private_key = file(var.lb_certificate_private_key)
  loadbalancer_public_certificate      = file(var.lb_public_certificate)

}
