locals {
  all_protocols     = "all"
  ad_names          = data.template_file.ad_names.*.rendered
  anywhere          = "0.0.0.0/0"
  ssh_port          = 22
  tcp_protocol      = 6
  instance_image_id = var.instance_image_id == "Oracle" ? data.oci_core_images.oracle_images.images.0.id : var.instance_image_id
  vcn_cidr          = data.oci_core_vcn.vcn.cidr_block
}
