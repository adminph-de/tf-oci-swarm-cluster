#!/bin/bash
SWARM_NODES=(`docker node ls --filter role=worker | awk 'NR>1{ print $2}'`)
echo "Adding Lables to WORKER Nodes:"
for i in ${!SWARM_NODES[@]}; do
    WORKER_IP=(`docker node inspect ${SWARM_NODES[$i]} | grep -e '"Addr": ' | awk -F '"' '{ print $4 }'`)
    WORKER_STATE=(`docker node inspect ${SWARM_NODES[$i]} | grep -e '"State": ' | awk -F '"' '{ print $4 }'`)
    [ $WORKER_STATE == "ready" ] && cat /var/nfsshare/metadata | grep -e "$WORKER_IP" | awk '{ system("docker node update --label-add region="$4 " " $2) }'
    [ $WORKER_STATE == "ready" ] && cat /var/nfsshare/metadata | grep -e "$WORKER_IP" | awk '{ system("docker node update --label-add ad="$5 " " $2) }'
    [ $WORKER_STATE == "ready" ] && cat /var/nfsshare/metadata | grep -e "$WORKER_IP" | awk '{ system("docker node update --label-add size="$6 " " $2) }'
done