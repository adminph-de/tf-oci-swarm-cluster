#!/bin/bash
exec 1> /var/log/cloud-init.docker 2>&1

# Deploy Traefik Loadbalancer (if enabled)
if [ "${oci_traefik_enabled}" = true ]; then
    docker network create -d overlay public
    mkdir -p /var/nfsshare/.traefik/log
    mkdir -p /var/nfsshare/.traefik/letsencrypt
    docker stack deploy -c /var/nfsshare/.docker/traefik.yaml traefik
    echo "Finished deployment of Traefik Loabalancer on host: `hostname --short` deployed....."
fi

# Wait 30s before go on with deploying the Portainer Stack
sleep 30

# Deploy Portainer (if enabled)
if [ "${oci_traefik_enabled}" = true ] && [ "${oci_portainer_enabled}" = true ]; then
docker network create -d overlay agent_network
docker stack deploy -c /var/nfsshare/.docker/portainer.yaml portainer
echo "Finished deployment of Portainer on host: `hostname --short` deployed....."
fi
