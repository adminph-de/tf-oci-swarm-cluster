output "core_instance_pool_worker" {
  value = oci_core_instance_pool.worker_pool
}

output "core_instance_worker" {
  value = data.oci_core_instance.instance
}

output "core_instance_configuration" {
  value = data.oci_core_instance_pool_instances.pool_instances
}

output "oci_core_instance_pool_instances" {
  value = data.oci_core_instance_pool_instances.pool_instances
}

output "oci_core_instance_pool" {
  value = data.oci_core_instance_pool.instance
}