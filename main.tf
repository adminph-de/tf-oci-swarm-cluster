# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY: INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

locals {

  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaazkqjclyhwbcf75aveuuvhx3gv5oy54qk2whde35vtohvfplsauma"
  user_ocid        = "ocid1.user.oc1..aaaaaaaa6gpp2yiphzrppzdyki6xem5lmyzl2jvvl6glgcv5tird65ox2iaa"
  fingerprint      = "10:cd:a7:82:4a:7e:eb:42:d0:70:49:19:f4:f8:14:83"
  private_key_path = "~/.oci/oci_api_key.flscloud.pem"
  region           = "us-ashburn-1"

  # Masrer Instance Name: ${var.label_prefix}-master-${var.label_postfix}
  # Worker Instance Name: ${var.label_prefix}-worker-${count.index + 1}-${var.label_postfix}
  label_prefix        = "oc2-test-swarm"
  label_postfix       = "s"
  ssh_public_key      = ""
  ssh_public_key_path = "./keys/webinit_rsa.pub"
  timezone            = "UTC"
  swarm_worker_count  = 2

}

provider "oci" {
  tenancy_ocid     = local.tenancy_ocid
  user_ocid        = local.user_ocid
  fingerprint      = local.fingerprint
  private_key_path = local.private_key_path
  region           = local.region
}

module "master" {
  source                       = "./modules/instance"
  instance_enabled             = true
  instance_region              = local.region
  instance_node_type           = "master"
  instance_tenancy_ocid        = "ocid1.tenancy.oc1..aaaaaaaazkqjclyhwbcf75aveuuvhx3gv5oy54qk2whde35vtohvfplsauma"
  instance_label_prefix        = local.label_prefix
  instance_label_postfix       = local.label_postfix
  instance_compartment_id      = "ocid1.compartment.oc1..aaaaaaaaensqjpvvvudpci3mubpsh3k5am7ftujsngn3reh3fjgpja2h37sq"
  instance_availability_domain = 1
  instance_vcn_id              = "ocid1.vcn.oc1.iad.amaaaaaanilxufiaatesgwfvnmux2t5eukj5fh64uw3fe5hg7z5fb46ejbcq"
  instance_subnet_id           = "ocid1.subnet.oc1.iad.aaaaaaaarfdqjbbtcdrecmmdmri63c6odcqfkn4x3jfnwz3ac2viclijpzjq"
  instance_nat_route_id        = ""
  instance_nsg_ids             = []
  # ImageId = (Region: us-ashburn-1, OS: CentOS-7-2021.03.16-0)
  instance_image_id           = "ocid1.image.oc1.iad.aaaaaaaanduaanydig5trp6s2pw2mn5lchwyqramyfjzezcarcdqry7yeo7a"
  instance_instance_principal = true
  instance_shape = {
    shape            = "VM.Standard.E3.Flex",
    ocpus            = 2,
    memory           = 12,
    boot_volume_size = 50
  }
  instance_upgrade             = true
  instance_ssh_public_key      = local.ssh_public_key
  instance_ssh_public_key_path = local.ssh_public_key_path
  instance_timezone            = local.timezone

  # Add one OCI repo (private access) to the Cluster
  swarm_oci_repo_enable               = true
  swarm_oci_repo_server               = "fra.ocir.io"
  swarm_oci_repo_username             = "flscloud/hpcuser"
  swarm_oci_repo_auth_secret          = "-YQb]STelMr7amz8CutR"
  swarm_oci_repo_auth_secret_encypted = "ZmxzY2xvdWQvaHBjdXNlcjotWVFiXVNUZWxNcjdhbXo4Q3V0Ug=="

  # Some Settings for Traefic Loadbalan
  swarm_traefik_fqdn = "oci-swarm.cloud.flsmidth.com"
}

module "worker" {
  source                       = "./modules/instance"
  count                        = local.swarm_worker_count
  instance_enabled             = true
  instance_region              = local.region
  instance_node_type           = "worker"
  instance_swarm_worker_count  = local.swarm_worker_count
  instance_swarm_master_ip     = module.master.instance_private_ip
  instance_tenancy_ocid        = "ocid1.tenancy.oc1..aaaaaaaazkqjclyhwbcf75aveuuvhx3gv5oy54qk2whde35vtohvfplsauma"
  instance_label_prefix        = local.label_prefix
  instance_label_postfix       = "${count.index + 1}-${local.label_postfix}"
  instance_compartment_id      = "ocid1.compartment.oc1..aaaaaaaaensqjpvvvudpci3mubpsh3k5am7ftujsngn3reh3fjgpja2h37sq"
  instance_availability_domain = count.index + 1
  instance_vcn_id              = "ocid1.vcn.oc1.iad.amaaaaaanilxufiaatesgwfvnmux2t5eukj5fh64uw3fe5hg7z5fb46ejbcq"
  instance_subnet_id           = "ocid1.subnet.oc1.iad.aaaaaaaarfdqjbbtcdrecmmdmri63c6odcqfkn4x3jfnwz3ac2viclijpzjq"
  instance_nat_route_id        = ""
  instance_nsg_ids             = []
  # ImageId = (Region: us-ashburn-1, OS: CentOS-7-2021.03.16-0)
  instance_image_id           = "ocid1.image.oc1.iad.aaaaaaaanduaanydig5trp6s2pw2mn5lchwyqramyfjzezcarcdqry7yeo7a"
  instance_instance_principal = true
  instance_shape = {
    shape            = "VM.Standard.E3.Flex",
    ocpus            = 2,
    memory           = 12,
    boot_volume_size = 50
  }
  instance_upgrade             = true
  instance_ssh_public_key      = local.ssh_public_key
  instance_ssh_public_key_path = local.ssh_public_key_path
  instance_timezone            = local.timezone
}

output "master_ip" {
  value = module.master.instance_private_ip
}
output "master_display_name" {
  value = module.master.instance_display_name
}
output "worker_ip" {
  value = module.worker[*].instance_private_ip
}
output "worker_display_name" {
  value = module.worker[*].instance_display_name
}
