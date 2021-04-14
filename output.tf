
output "loadbalancer" {
  value = "Before you can access the Portainer URL, you need to add '${format(lookup(module.loadbalancer.load_balancer_swarm[0].ip_address_details[0], "ip_address"))} A-RECORD ${element(split(".", module.loadbalancer.balancer_hostname[0].hostname), 0)}' to your DNS zone: ${trimprefix(element(split("${element(split(".", module.loadbalancer.balancer_hostname[0].hostname), 0)}.", module.loadbalancer.balancer_hostname[0].hostname), 1), module.loadbalancer.balancer_hostname[0].hostname)}"
}
output "loadbalancer_display_name" {
  value = module.loadbalancer.load_balancer_swarm[0].display_name
}
output "loadbalancer_ip_url" {
  #value = module.loadbalancer.load_balancer_swarm[0].ip_addresses
  value = format("http://%s", lookup(module.loadbalancer.load_balancer_swarm[0].ip_address_details[0], "ip_address"))
}
output "loadbalancer_portainer_url" {
  value = "https://${module.loadbalancer.balancer_hostname[0].hostname}"
}
output "swarm_master_display_name" {
  value = module.master.instance_display_name
}
output "swarm_master_ip" {
  value = module.master.instance_private_ip
}
output "swarm_single_worker_instance_display_names" {
  value = module.worker[*].instance_display_name
}
output "swarm_single_worker_instance_ips" {
  value = module.worker[*].instance_private_ip
}

output "swarm_pool_worker_display_name" {
  value = module.pool.oci_core_instance_pool[0].display_name
}
output "swarm_pool_worker_instnace_count" {
  value = module.pool.core_instance_pool_worker[0].size
}

output "swarm_pool_worker_instnaces_name" {
  value = local.worker_pool_node_count > 0 ? flatten(split(",", join(",", lookup(module.pool.oci_core_instance_pool_instances[0], "instances", null).*.display_name))) : null
}

