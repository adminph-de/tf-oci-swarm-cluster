#!/bin/bash

# Create Log directory for Traefik Loabalancer
mkdir -p /var/log/traefik
# Deploy Swarm Networks for Loabalancer and Portainer agents
docker network create -d overlay lb_network
docker network create -d overlay agent_network
# Deploy Traefik Loadbalancer
docker stack deploy -c /var/nfsshare/.docker/swarm.yaml swarm

echo "Traefik Loabalancer on host: `hostname --short` deployed....."