#!/bin/bash
SWARM_NODES=(`docker node ls --filter role=worker --quiet | awk '{ print $1}'`)
echo "Adding Lable region=$1 to WORKER Nodes:"
for i in $${!SWARM_NODES[@]}; do
    docker node update --label-add region=$1 $${SWARM_NODES[$i]}
done