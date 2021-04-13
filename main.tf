module "master" {
  source = "./modules/instance"

  instance_enabled = true

  instance_tenancy_ocid        = local.tenancy_ocid
  instance_region              = local.region
  instance_node_type           = "master"
  instance_label_prefix        = local.label_prefix
  instance_label_postfix       = local.label_postfix
  instance_compartment_id      = (local.master_compartment_id != "") ? local.master_compartment_id : local.compartment_id
  instance_availability_domain = 1
  instance_vcn_id              = (local.master_vcn_id != "") ? local.master_vcn_id : local.vcn_id
  instance_subnet_id           = (local.master_subnet_id != "") ? local.master_subnet_id : local.subnet_id
  instance_nat_route_id        = ""
  instance_nsg_ids             = []
  instance_image_id            = (local.master_image_id != "") ? local.master_image_id : local.image_id
  instance_shape               = (local.master_shape != {}) ? local.master_shape : local.shape
  instance_upgrade             = true
  instance_ssh_public_key      = local.ssh_public_key
  instance_ssh_public_key_path = local.ssh_public_key_path
  instance_timezone            = local.timezone

  swarm_oci_repo_enable               = local.oci_repo_enable
  swarm_oci_repo_server               = local.oci_repo_server
  swarm_oci_repo_username             = local.oci_repo_username
  swarm_oci_repo_auth_secret          = local.oci_repo_auth_secret
  swarm_oci_repo_auth_secret_encypted = local.oci_repo_auth_secret_encypted

  swarm_oci_fqdn_portainer = local.lb_host_name
}

module "worker" {
  source = "./modules/instance"
  count  = local.worker_node_count

  instance_enabled = local.worker_enabled

  instance_tenancy_ocid        = local.tenancy_ocid
  instance_region              = local.region
  instance_node_type           = "worker"
  instance_swarm_worker_count  = local.worker_node_count
  instance_swarm_master_ip     = module.master.instance_private_ip
  instance_label_prefix        = local.label_prefix
  instance_label_postfix       = "${count.index + 1}-${local.label_postfix}"
  instance_compartment_id      = local.worker_compartment_id != "" ? local.worker_compartment_id : local.compartment_id
  instance_availability_domain = count.index + 1
  instance_vcn_id              = (local.worker_vcn_id != "") ? local.worker_vcn_id : local.vcn_id
  instance_subnet_id           = (local.worker_subnet_id != "") ? local.worker_subnet_id : local.subnet_id
  instance_nat_route_id        = ""
  instance_nsg_ids             = []
  instance_image_id            = (local.worker_image_id != "") ? local.worker_image_id : local.image_id
  instance_shape               = (local.worker_shape != {}) ? local.worker_shape : local.shape
  instance_upgrade             = true
  instance_ssh_public_key      = local.ssh_public_key
  instance_ssh_public_key_path = local.ssh_public_key_path
  instance_timezone            = local.timezone
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  loadbalancer_enabled = local.lb_enable

  loadbalancer_is_private              = local.lb_is_private
  loadbalancer_compartment_id          = (local.lb_compartment_id != "") ? local.lb_compartment_id : local.compartment_id
  loadbalancer_name_prefix             = local.label_prefix
  loadbalancer_name_postfix            = local.label_postfix
  loadbalancer_vcn_id                  = (local.lb_vcn_id != "") ? local.lb_vcn_id : local.vcn_id
  loadbalancer_subnet_id               = (local.lb_subnet_id != "") ? local.lb_subnet_id : local.subnet_id
  loadbalancer_shape                   = local.lb_shape
  loadbalancer_hostname_name           = local.lb_host_name
  loadbalancer_swarm_backend           = module.master.instance_private_ip
  loadbalancer_certificate_name        = local.lb_certificate_name
  loadbalancer_passphrase              = local.lb_passphrase
  loadbalancer_ca_certificate          = local.lb_ca_certificate
  loadbalancer_certificate_private_key = local.lb_certificate_private_key
  loadbalancer_public_certificate      = local.lb_public_certificate

}
