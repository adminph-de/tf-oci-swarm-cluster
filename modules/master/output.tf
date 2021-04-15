output "instance_private_ip" {
  value = join(",", data.oci_core_vnic.instance_vnic.*.private_ip_address)
}
output "instance_display_name" {
  value = join(",", data.oci_core_instance.instance.*.display_name)
}
