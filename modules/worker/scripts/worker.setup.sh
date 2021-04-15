#!/bin/bash
exec 1> /var/log/cloud-init.script 2>&1

yum -y update
yum -y install python3 git curl wget telnet ansible
pip3 install oci-cli

sed -i -e 's/SELINUX=enforcing/SELINUX=disable/' /etc/selinux/config
setenforce 0

# Set new Hostname
hostnamectl set-hostname `curl -L -s http://169.254.169.254/opc/v1/instance/displayName | awk -F '-' '{print $1 "-" $2}'`

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

# Mount the NFS share of the Swam Cluster Master
[ ! -d /var/nfsshare ] && mkdir /var/nfsshare
chmod -R 755 /var/nfsshare
chown opc:opc /var/nfsshare
mount -o vers=3 ${oci_swarm_master_ip}:/var/nfsshare /var/nfsshare
echo "${oci_swarm_master_ip}:/var/nfsshare  /var/nfsshare  nfs  defaults,noatime,_netdev  0  0" >> /etc/fstab

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

echo "`hostname --all-ip-addresses | awk '{ print $1 }'` `hostname --all-fqdns | awk '{ print $3 }'` `hostname --all-fqdns | awk -F '.' '{ print $1 }'` `hostname --all-fqdns | awk -F ' ' '{ print $1 }'`" >> /var/nfsshare/hosts
rm /etc/hosts
ln -s /var/nfsshare/hosts /etc/hosts

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

# add Master Node SSH Public key to authorized_keys for user opc
cat /var/nfsshare/.ssh/id_rsa.pub >> /home/opc/.ssh/authorized_keys

# Write Instance Metadate
echo "`hostname --all-ip-addresses | awk '{ print $1 }'` `curl -L -s http://169.254.169.254/opc/v1/instance/hostname` `curl -L -s http://169.254.169.254/opc/v1/instance/id` `curl -L -s http://169.254.169.254/opc/v1/instance/canonicalRegionName` `curl -L -s http://169.254.169.254/opc/v1/instance/availabilityDomain` `curl -L -s http://169.254.169.254/opc/v1/instance/shape`" >> /var/nfsshare/metadata

exec /var/nfsshare/worker.join.sh

echo "Docker Swarm Worker Node: `hostname --short` finalized....."