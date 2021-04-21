#!/bin/bash
exec 1> /var/log/cloud-init.script 2>&1

yum -y update
yum -y install python3 git curl wget telnet ansible
pip3 install oci-cli

sed -i -e 's/SELINUX=enforcing/SELINUX=disable/' /etc/selinux/config
setenforce 0

# Install Docker-CE
yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce

# Add current User to "docker" group
usermod -aG docker opc
systemctl start docker
systemctl enable docker

# Install Docker plugin(s) Volume Driver
# GlusterFS
docker plugin install --alias glusterfs mochoa/glusterfs-volume-plugin --grant-all-permissions --disable
# s3fs
docker plugin install --alias s3fs mochoa/s3fs-volume-plugin --grant-all-permissions --disable
# NFS (NetShare)
curl -L "https://github.com/ContainX/docker-volume-netshare/releases/download/v0.36/docker-volume-netshare_0.36_linux_amd64-bin" -o /usr/bin/docker-volume-netshare
chmod +x /usr/bin/docker-volume-netshare
echo "DKV_NETSHARE_OPTS=nfs" > /etc/sysconfig/docker-volume-netshare
cat << 'EOF' > /usr/lib/systemd/system/docker-volume-netshare.service
[Unit]
Description=Docker NFS, AWS EFS & Samba/CIFS Volume Plugin
Documentation=https://github.com/gondor/docker-volume-netshare
After=nfs-utils.service
Before=docker.service
Requires=nfs-utils.service


[Service]
EnvironmentFile=/etc/sysconfig/docker-volume-netshare
ExecStart=/usr/bin/docker-volume-netshare $DKV_NETSHARE_OPTS
StandardOutput=syslog

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable docker-volume-netshare
systemctl start docker-volume-netshare
systemctl status docker-volume-netshare.service

# Create the directory that will be shared by NFS
mkdir /var/nfsshare
mkdir -p /var/nfsshare/.ansible
mkdir -p /var/nfsshare/.docker
mkdir -p /var/nfsshare/.traefik
mkdir -p /var/nfsshare/.portainer
mkdir -p /var/nfsshare/.ssh
# Change the permissions of the folder
chmod -R 755 /var/nfsshare
chown nfsnobody:nfsnobody /var/nfsshare
# Start the services and enable them to be started at boot time
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
# Make a sharing points /var/nfsshare
cat << 'EOF' >> /etc/exports
/var/nfsshare            *(rw,sync,no_root_squash,no_all_squash)
/var/nfsshare/.ansible   *(rw,sync,no_root_squash,no_all_squash)
/var/nfsshare/.docker    *(rw,sync,no_root_squash,no_all_squash)
/var/nfsshare/.traefic   *(rw,sync,no_root_squash,no_all_squash)
/var/nfsshare/.portainer *(rw,sync,no_root_squash,no_all_squash)
EOF
# Restart NFS service to enable the sharing
systemctl restart nfs-server
# Open Firewall for NFS
firewall-offline-cmd --add-service=nfs
firewall-offline-cmd --add-service=mountd
firewall-offline-cmd --add-service=rpc-bind
systemctl restart firewalld.service

# Create a new hosts file and link it to /etc/hosts
cat << EOF > /var/nfsshare/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF
echo "`hostname --ip-address | awk '{ print $1 }'` `hostname --fqdn` `hostname --short`" >> /var/nfsshare/hosts
rm -f /etc/hosts
ln -s /var/nfsshare/hosts /etc/hosts

if [ "${oci_swarm_repo_enable}"== "true" ]; then
[ ! -d /home/opc/.docker ] && mkdir /home/opc/.docker
cat << 'EOF' > /home/opc/.docker/config.json 
{
	"auths": {
		"${oci_repo_server}": {
			"auth": "${oci_repo_auth_secret_encypted}"
		}
	}
}
EOF
chown -R opc.opc /home/opc/.docker
chmod 600 /home/opc/.docker/config.json
cat << 'EOF' > /var/nfsshare/.docker/config.json 
{
  "ServerURL": "https://${oci_repo_server}/v1",
  "Username": "${oci_repo_username}",
  "Secret": "${oci_repo_auth_secret}"
}
EOF
fi

# Inial Docker Swarm on the Master Node
docker swarm init

# Open Firewall for Docker SWARM comunication
firewall-offline-cmd --add-service=docker-swarm
firewall-offline-cmd --add-port=2376/tcp
firewall-offline-cmd --add-port=2377/tcp
firewall-offline-cmd --add-port=7946/tcp
firewall-offline-cmd --add-port=7946/udp
firewall-offline-cmd --add-port=4789/udp
# Open Firewall for http/https traffic
firewall-offline-cmd --add-service=http
firewall-offline-cmd --add-service=https
firewall-offline-cmd --add-port=80/tcp
firewall-offline-cmd --add-port=443/tcp
systemctl restart firewalld.service

# Generate Worker Token and create /var/nfsshare/worker.join.sh
echo "docker swarm join --token `docker swarm join-token worker --quiet` `hostname --ip-address | awk '{ print $1 }'`:2377" > /var/nfsshare/worker.join.sh
chmod +x /var/nfsshare/worker.join.sh

# Generate a cron jop that runs every 10 minutes and applyies the region
# to all the workers in the Swarm Cluster.
touch /var/log/oci-swarm.log
chown opc.opc /var/log/oci-swarm.log
chmod 644 /var/log/oci-swarm.log
bash -c "(crontab -u opc -l; echo \"*/10 * * * * /var/nfsshare/.docker/note.lable.sh >> /var/log/oci-swarm.log 2>&1\") | crontab -u opc -"
cat << EOF > /etc/logrotate.d/oci-swarm
/var/log/oci-swarm.log {
    monthly
    create 0644 opc opc
    rotate 5
    size=1M
    compress
}
EOF

# Create a RSA Key for user opc
ssh-keygen -f /home/opc/.ssh/id_rsa -t rsa -N '' -q
chown opc.opc home/opc/.ssh/id_rsa
chmod 600 home/opc/.ssh/id_rsa
chmod 644 home/opc/.ssh/id_rsa.pub
# Copy the public key to the NFS Share
cp -f /home/opc/.ssh/id_rsa.pub /var/nfsshare/.ssh/id_rsa.pub

# Write Instance Metadate
echo "`hostname --all-ip-addresses | awk '{ print $1 }'` `curl -L -s http://169.254.169.254/opc/v1/instance/hostname` `curl -L -s http://169.254.169.254/opc/v1/instance/id` `curl -L -s http://169.254.169.254/opc/v1/instance/canonicalRegionName` `curl -L -s http://169.254.169.254/opc/v1/instance/availabilityDomain` `curl -L -s http://169.254.169.254/opc/v1/instance/shape`" >> /var/nfsshare/metadata


# Depoy Traefik and Portainer
exec /var/nfsshare/.docker/swarm.sh

echo "Docker Swarm Master Node: `hostname --short` finalized....."