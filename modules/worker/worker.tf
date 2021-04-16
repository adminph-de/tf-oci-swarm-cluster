resource "oci_core_instance_configuration" "swarm_worker" {
  compartment_id = var.instance_compartment_id
  display_name   = "${var.instance_label_prefix}-instance-config-${var.instance_label_postfix}"

  instance_details {
    instance_type = "compute"
    launch_details {
      availability_domain = element(data.template_file.ad_names.*.rendered, (var.instance_availability_domain - 1))
      compartment_id      = var.instance_compartment_id
      display_name        = "${var.instance_label_prefix}-worker"
      launch_mode         = "NATIVE"
      metadata = {
        ssh_authorized_keys = var.instance_ssh_public_key != "" ? var.instance_ssh_public_key : file(var.instance_ssh_public_key_path)
        user_data           = data.template_cloudinit_config.instance_worker[0].rendered
      }
      agent_config {
        are_all_plugins_disabled = false
        is_management_disabled   = true
        is_monitoring_disabled   = false
      }
      availability_config {
        recovery_action = "RESTORE_INSTANCE"
      }
      create_vnic_details {
        assign_public_ip = false
        display_name     = "${var.instance_label_prefix}-worker"
        subnet_id        = var.instance_subnet_id
      }
      instance_options {
        are_legacy_imds_endpoints_disabled = false
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
        image_id    = var.instance_image_id == "Oracle" ? data.oci_core_images.oracle_images.images.0.id : var.instance_image_id
        source_type = "image"
      }
    }
  }
  lifecycle {
    ignore_changes = [
      instance_details[0].launch_details[0].source_details[0].image_id,
      # disbale if a script content changed
      instance_details[0].launch_details[0].metadata
    ]
  }
  count = var.instance_enabled == true ? 1 : 0
}

resource "oci_core_instance_pool" "worker_pool" {
  compartment_id            = var.instance_compartment_id
  instance_configuration_id = oci_core_instance_configuration.swarm_worker[0].id
  display_name              = "${var.instance_label_prefix}-worker-pool-${var.instance_label_postfix}"
  placement_configurations {
    availability_domain = element(data.template_file.ad_names.*.rendered, (var.instance_availability_domain - 1))
    primary_subnet_id   = var.instance_subnet_id
  }
  size = var.instance_swarm_worker_count

  count = var.instance_enabled == true ? 1 : 0
}
