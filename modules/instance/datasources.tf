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
# NETWORK
# --------------------------------------------------------------------------------------------

data "oci_core_vcn" "vcn" {
  vcn_id = var.instance_vcn_id
}
data "oci_core_vnic_attachments" "instance_vnics_attachments" {
  availability_domain = element(data.template_file.ad_names.*.rendered, (var.instance_availability_domain - 1))
  compartment_id      = var.instance_compartment_id
  instance_id         = oci_core_instance.instance[0].id
  depends_on          = [oci_core_instance.instance]
  count               = var.instance_enabled == true ? 1 : 0
}
data "oci_core_vnic" "instance_vnic" {
  vnic_id    = lookup(data.oci_core_vnic_attachments.instance_vnics_attachments[0].vnic_attachments[0], "vnic_id")
  depends_on = [oci_core_instance.instance]
  count      = var.instance_enabled == true ? 1 : 0
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
  instance_id = oci_core_instance.instance[0].id
  depends_on  = [oci_core_instance.instance]
  count       = var.instance_enabled == true ? 1 : 0
}
data "template_cloudinit_config" "instance_master" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "operator.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.master_cloud_init[0].rendered
  }
  count = var.instance_enabled == true && var.instance_node_type == "master" ? 1 : 0
}
data "template_cloudinit_config" "instance_worker" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "operator.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.worker_cloud_init[0].rendered
  }
  count = var.instance_enabled == true && var.instance_node_type == "worker" && var.instance_swarm_worker_count >= 1 ? 1 : 0
}

# --------------------------------------------------------------------------------------------
# CLOUD-INIT: Instance Scripts
# --------------------------------------------------------------------------------------------

# master.template.yaml
data "template_file" "master_cloud_init" {
  template = file("${path.module}/cloudinit/master.template.yaml")
  vars = {
    instance_upgrade        = var.instance_upgrade
    timezone                = var.instance_timezone
    master_setup_sh_content = base64gzip(data.template_file.master_setup[0].rendered)
    note_lable_sh_content   = base64gzip(data.template_file.note_lable_sh[0].rendered)
    swarm_sh_content        = base64gzip(data.template_file.swarm_sh[0].rendered)
    swarm_yaml_content      = base64gzip(data.template_file.swarm_yaml[0].rendered)
  }
  count = var.instance_enabled == true && var.instance_node_type == "master" ? 1 : 0
}
data "template_file" "master_setup" {
  template = file("${path.module}/scripts/master.setup.sh")
  vars = {
    oci_swarm_region              = var.instance_region
    oci_swarm_repo_enable         = var.swarm_oci_repo_enable
    oci_repo_server               = var.swarm_oci_repo_server
    oci_repo_username             = var.swarm_oci_repo_username
    oci_repo_auth_secret          = var.swarm_oci_repo_auth_secret
    oci_repo_auth_secret_encypted = var.swarm_oci_repo_auth_secret_encypted

  }
  count = var.instance_enabled == true && var.instance_node_type == "master" ? 1 : 0
}
data "template_file" "note_lable_sh" {
  template = file("${path.module}/scripts/node.lable.sh")
  count    = var.instance_enabled == true && var.instance_node_type == "master" ? 1 : 0
}
data "template_file" "swarm_sh" {
  template = file("${path.module}/scripts/swarm.sh")
  count    = var.instance_enabled == true && var.instance_node_type == "master" ? 1 : 0
}
data "template_file" "swarm_yaml" {
  template = file("${path.module}/scripts/swarm.yaml")
  count    = var.instance_enabled == true && var.instance_node_type == "master" ? 1 : 0
  vars = {
    oci_swarm_traefik_fqdn = var.swarm_traefik_fqdn
  }
}

# worker.template.sh
data "template_file" "worker_cloud_init" {
  template = file("${path.module}/cloudinit/worker.template.yaml")
  vars = {
    instance_upgrade        = var.instance_upgrade
    timezone                = var.instance_timezone
    worker_setup_sh_content = base64gzip(data.template_file.worker_setup[0].rendered)
  }
  count = var.instance_enabled == true && var.instance_node_type == "worker" && var.instance_swarm_worker_count >= 1 ? 1 : 0
}
data "template_file" "worker_setup" {
  template = file("${path.module}/scripts/worker.setup.sh")
  vars = {
    oci_swarm_master_ip           = var.instance_swarm_master_ip
    oci_swarm_region              = var.instance_region
    oci_repo_server               = var.swarm_oci_repo_server
    oci_repo_auth_secret_encypted = var.swarm_oci_repo_auth_secret_encypted
  }
  count = var.instance_enabled == true && var.instance_node_type == "worker" && var.instance_swarm_worker_count >= 1 ? 1 : 0
}
