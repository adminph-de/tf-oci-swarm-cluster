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
  count = var.instance_enabled == true ? 1 : 0
}

# --------------------------------------------------------------------------------------------
# CLOUD-INIT: Instance Scripts
# --------------------------------------------------------------------------------------------

data "template_file" "master_cloud_init" {
  template = file("${path.module}/cloudinit/master.template.yaml")
  vars = {
    instance_upgrade        = var.instance_upgrade
    timezone                = var.instance_timezone
    master_setup_sh_content = base64gzip(data.template_file.master_setup[0].rendered)
    note_lable_sh_content   = base64gzip(data.template_file.note_lable_sh[0].rendered)
    swarm_sh_content        = base64gzip(data.template_file.swarm_sh[0].rendered)
    traefik_yaml_content    = base64gzip(data.template_file.traefik_yaml[0].rendered)
    portainer_yaml_content  = base64gzip(data.template_file.portainer_yaml[0].rendered)
  }
  count = var.instance_enabled == true ? 1 : 0
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
  count = var.instance_enabled == true ? 1 : 0
}
data "template_file" "note_lable_sh" {
  template = file("${path.module}/scripts/node.lable.sh")
  vars = {
    oci_traefik_enabled        = var.swarm_traefik_enabled
    oci_traefik_dashboard_fqdn = var.swarm_traefik_dashboard_fqdn
    oci_portainer_enabled      = var.swarm_portainer_enabled
    oci_portainer_fqdn         = var.swarm_portainer_fqdn
  }
  count = var.instance_enabled == true ? 1 : 0
}
data "template_file" "swarm_sh" {
  template = file("${path.module}/scripts/swarm.sh")
  count    = var.instance_enabled == true ? 1 : 0
  vars = {
    oci_traefik_enabled        = var.swarm_traefik_enabled
    oci_traefik_dashboard_fqdn = var.swarm_traefik_dashboard_fqdn
    oci_portainer_enabled      = var.swarm_portainer_enabled
    oci_portainer_fqdn         = var.swarm_portainer_fqdn
  }
}
data "template_file" "traefik_yaml" {
  template = file("${path.module}/scripts/traefik.yaml")
  count    = var.instance_enabled == true && var.swarm_traefik_enabled == true ? 1 : 0
  vars = {
    oci_traefik_dashboard_fqdn  = var.swarm_traefik_dashboard_fqdn
    oci_traefik_dashboard_login = var.swarm_traefik_dashboard_login
  }
}
data "template_file" "portainer_yaml" {
  template = file("${path.module}/scripts/portainer.yaml")
  count    = var.instance_enabled == true && var.swarm_portainer_enabled == true ? 1 : 0
  vars = {
    oci_portainer_fqdn = var.swarm_portainer_fqdn
    oci_edge_fqdn      = var.swarm_portainer_edge_fqdn
  }
}
