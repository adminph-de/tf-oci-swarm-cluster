output "load_balancer_swarm" {
  value = oci_load_balancer_load_balancer.swarm
}
output "balancer_hostname" {
  value = oci_load_balancer_hostname.oci_swarm_hostname
}
