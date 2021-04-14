# --------------------------------------------------------------------------------------------
# OCI TENANT DATA
# --------------------------------------------------------------------------------------------

data "oci_identity_availability_domains" "ad_list" {
  compartment_id = var.instance_tenancy_ocid
}
data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ad_list.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ad_list.availability_domains[count.index], "name")
}
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.instance_tenancy_ocid
}
data "oci_identity_regions" "home_region" {
  filter {
    name = "key"
    # Tenancy's home region
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

# --------------------------------------------------------------------------------------------
# MISC
# --------------------------------------------------------------------------------------------

resource "random_integer" "rnd" {
  min = 1
  max = 9999
}

# --------------------------------------------------------------------------------------------
# INSTANCE
# --------------------------------------------------------------------------------------------

data "oci_core_images" "oracle_images" {
  compartment_id           = var.instance_compartment_id
  operating_system         = var.instance_operating_system
  operating_system_version = var.instance_operating_system_version
  shape                    = lookup(var.instance_shape, "shape", "VM.Standard.E2.2")
  sort_by                  = "TIMECREATED"
}
data "oci_core_instance" "instance" {
  instance_id = oci_core_instance_configuration.swarm_worker[0].id
  depends_on  = [oci_core_instance_configuration.swarm_worker]
  count       = var.instance_enabled == true ? 1 : 0
}

data "template_cloudinit_config" "instance_worker" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "operator.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.worker_cloud_init[0].rendered
  }
  count = var.instance_enabled == true && var.instance_swarm_worker_count >= 1 ? 1 : 0
}

# --------------------------------------------------------------------------------------------
# CLOUD-INIT: Instance Scripts
# --------------------------------------------------------------------------------------------

data "template_file" "worker_setup" {
  template = file("${path.module}/scripts/worker.setup.sh")
  vars = {
    oci_swarm_master_ip           = var.instance_swarm_master_ip
    oci_swarm_region              = var.instance_region
    oci_repo_server               = var.swarm_oci_repo_server
    oci_repo_auth_secret_encypted = var.swarm_oci_repo_auth_secret_encypted
  }
  count = var.instance_enabled == true && var.instance_swarm_worker_count >= 1 ? 1 : 0
}

data "template_file" "worker_cloud_init" {
  template = file("${path.module}/cloudinit/worker.template.yaml")
  vars = {
    instance_upgrade        = var.instance_upgrade
    timezone                = var.instance_timezone
    worker_setup_sh_content = base64gzip(data.template_file.worker_setup[0].rendered)
  }
  count = var.instance_enabled == true && var.instance_swarm_worker_count >= 1 ? 1 : 0
}