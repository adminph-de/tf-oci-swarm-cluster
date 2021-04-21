# output "portainer" {
#   value = var.portainer_enabled == true ? "Before you can access the Portainer URL, you need to add ${var.portainer_fqdn} A-RECORD ${element(split(".", module.loadbalancer.balancer_hostname[0].hostname), 0)}' to your DNS zone: ${trimprefix(element(split("${element(split(".", module.loadbalancer.balancer_hostname[0].hostname), 0)}.", module.loadbalancer.balancer_hostname[0].hostname), 1), module.loadbalancer.balancer_hostname[0].hostname)}\nDashboard URL: https://{var.portainer_fqdn}" : " "
# }

# output "traefik" {
#   value = var.traefik_enabled == true ? "Before you can access the Trasefik Dashboard URL, you need to add '${format(lookup(module.loadbalancer.load_balancer_swarm[0].ip_address_details[0], "ip_address"))} A-RECORD ${element(split(".", module.loadbalancer.balancer_hostname[0].hostname), 0)}' to your DNS zone: ${trimprefix(element(split("${element(split(".", module.loadbalancer.balancer_hostname[0].hostname), 0)}.", module.loadbalancer.balancer_hostname[0].hostname), 1), module.loadbalancer.balancer_hostname[0].hostname)}\nDashboard URL: https://${module.loadbalancer.balancer_hostname[0].hostname}/traefik" : " "
# }

output "loadbalancer_display_name" {
  value = module.loadbalancer.load_balancer_swarm[0].display_name
}
output "loadbalancer_ip_url" {
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

output "URLs" {
  value = "- https://${var.traefik_dashboard_fqdn}/traefik (Traefik Dashboard)\n- https://${var.portainer_fqdn} (Portainer Portal)\n- https://${var.portainer_edge_fqdn} (Portainer Edge Service)"
}

output "use_ssh_config" {
  value = "\nAdd the following configuration to your ~/.ssh/config file\nUse the BASTION (proxy) to ssh into the Swarm Master Node:\n\nHost bastion\n HostName 130.61.238.203\n ForwardAgent  yes\n User opc\n IdentityFile ~/.ssh/webint_rsa\n\nHost swarm-master\n Hostname ${module.master.instance_private_ip}\n ForwardAgent yes\n User opc\n IdentityFile ~/.ssh/webint_rsa\n ProxyJump bastion"
}
