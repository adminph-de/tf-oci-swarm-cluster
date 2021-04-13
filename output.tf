output "swarm_master_ip" {
  value = module.master.instance_private_ip
}
output "swarm_master_display_name" {
  value = module.master.instance_display_name
}
output "swarm_worker_ip" {
  value = module.worker[*].instance_private_ip
}
output "swarm_worker_display_name" {
  value = module.worker[*].instance_display_name
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
