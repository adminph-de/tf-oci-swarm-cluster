
resource "oci_core_instance" "instance" {
  availability_domain = element(local.ad_names, (var.instance_availability_domain - 1))
  compartment_id      = var.instance_compartment_id
  display_name        = var.instance_node_type == "master" ? "${var.instance_label_prefix}-master-${var.instance_label_postfix}" : "${var.instance_label_prefix}-worker-${var.instance_label_postfix}"
  agent_config {
    is_management_disabled = true
  }
  create_vnic_details {
    assign_public_ip = false
    display_name     = var.instance_node_type == "master" ? "${var.instance_label_prefix}-master-${var.instance_label_postfix}" : "${var.instance_label_prefix}-worker-${var.instance_label_postfix}"
    nsg_ids          = var.instance_nsg_ids
    subnet_id        = var.instance_subnet_id
  }
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    network_type     = "PARAVIRTUALIZED"
  }
  # prevent the operator from destroying and recreating itself if the image ocid changes 
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
  metadata = {
    ssh_authorized_keys = var.instance_ssh_public_key != "" ? var.instance_ssh_public_key : file(var.instance_ssh_public_key_path)
    user_data           = var.instance_node_type == "master" ? data.template_cloudinit_config.instance_master[0].rendered : data.template_cloudinit_config.instance_worker[0].rendered
  }
  shape = lookup(var.instance_shape, "shape", "VM.Standard.E2.2")
  dynamic "shape_config" {
    for_each = length(regexall("Flex", lookup(var.instance_shape, "shape", "VM.Standard.E3.Flex"))) > 0 ? [1] : []
    content {
      ocpus         = max(1, lookup(var.instance_shape, "ocpus", 1))
      memory_in_gbs = (lookup(var.instance_shape, "memory", 4) / lookup(var.instance_shape, "ocpus", 1)) > 64 ? (lookup(var.instance_shape, "ocpus", 1) * 4) : lookup(var.instance_shape, "memory", 4)
    }
  }
  source_details {
    source_type = "image"
    source_id   = var.instance_image_id == "Oracle" ? data.oci_core_images.oracle_images.images.0.id : var.instance_image_id
  }
  timeouts {
    create = "60m"
  }
  count = var.instance_enabled == true ? 1 : 0
}
