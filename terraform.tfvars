# Oracle Cloud Access Settings
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaazkqjclyhwbcf75aveuuvhx3gv5oy54qk2whde35vtohvfplsauma" # flscloud
user_ocid        = "ocid1.user.oc1..aaaaaaaa6gpp2yiphzrppzdyki6xem5lmyzl2jvvl6glgcv5tird65ox2iaa"
fingerprint      = "10:cd:a7:82:4a:7e:eb:42:d0:70:49:19:f4:f8:14:83"
private_key_path = "~/.oci/oci_api_key.flscloud.pem"
region           = "us-ashburn-1"

# Global Defaults
label_prefix        = "oc2-hpc-swarm"
label_postfix       = "p"
ssh_public_key      = ""
ssh_public_key_path = "./keys/webinit_rsa.pub"
timezone            = "UTC"
compartment_id      = "ocid1.compartment.oc1..aaaaaaaaensqjpvvvudpci3mubpsh3k5am7ftujsngn3reh3fjgpja2h37sq" # PoC:HPC:ROCKY:Applications
vcn_id              = "ocid1.vcn.oc1.iad.amaaaaaanilxufiaatesgwfvnmux2t5eukj5fh64uw3fe5hg7z5fb46ejbcq"
subnet_id           = "ocid1.subnet.oc1.iad.aaaaaaaarfdqjbbtcdrecmmdmri63c6odcqfkn4x3jfnwz3ac2viclijpzjq"
image_id            = "ocid1.image.oc1.iad.aaaaaaaanduaanydig5trp6s2pw2mn5lchwyqramyfjzezcarcdqry7yeo7a" # Region: us-ashburn-1, OS: CentOS-7-2021.03.16-0 4605
instance_shape = {
  shape            = "VM.Standard.E3.Flex",
  ocpus            = 2,
  memory           = 12,
  boot_volume_size = 50
}

# Swarm MASTER Node
master_compartment_id = ""   # optional, default = var.compartment_id
master_ad             = 1
master_vcn_id         = ""   # optional, default = var.vnc_id
master_subnet_id      = ""   # optional, default = var.subnet_id
master_image_id       = ""   # optional, default = var.image_id
master_shape          = {}   # optional, default = var.shape_id

# Swarm WORKER pool(s)
# Define and add your worker pools to the deployment.
# use a list object (example):
# - comment: ocpus, and memory is only needed for FLEX types.
# micro01 = {
#     enabled        = true
#     node_count     = 1
#     region         = ""
#     ad             = 1
#     compartment_id = ""
#     os_upgrade     = true
#     vcn_id         = "" 
#     subnet_id      = ""
#     image_id       = ""
#     worker_shape   = {
#       shape            = "VM.Standard.E2.1.Micro",
#       ocpus            = 1,
#       memory           = 2,
#       boot_volume_size = 20
#     }
# }

worker_map = {
  nogpu01 = {
    enabled        = true
    node_count     = 4
    region         = ""       # optional, default = var.region
    ad             = 2 
    compartment_id = ""       # optional, default = var.compartment_id
    os_upgrade     = false
    vcn_id         = ""       # optional, default = var.vnc_id
    subnet_id      = ""       # optional, default = var.subnet_id
    image_id       = ""       # optional, default = var.image_id
    worker_shape   = {}       # optional, default = var.shape_id
  }
}

# Swarm OCI Loadbalancer
lb_is_private     = false    # optional, default = false
lb_compartment_id = ""
# if you use public Loadbalancer, be sure lb_is_private is set to false
# and choose a VCN and Subnet that provides Public IPs. Otherwiese the deployment fails.
lb_vcn_id    = "ocid1.vcn.oc1.iad.amaaaaaanilxufianppjygzpznnksymz6lguuboshu6smxe46low3dx3f5vq"    # Region: us-ashburn-1,oc2-vcn-rocky-hpc-hub-s
lb_subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaaujiza35rvufevk6jd4q26nglzw7i6dkkjkbmkf47mq6aflel5abq" # Region: us-ashburn-1,oc2-sub-rocky-hpc-hub-1-s
lb_shape     = "flexible"
lb_host_name = "oci-swarm.cloud.flsmidth.com"
## How to Create a Loadbalancer SSL Certificate
# CA Certificate
# openssl req -x509 -nodes -newkey rsa:4096 -keyout ca.key -out ca.crt -days 3650
# Serive Certifiace
# openssl genrsa -out swarm_cert.key 2048
# openssl req -new -sha256 -key swarm_cert.key -subj "/C=DK/ST=Copenhagen/O=FLSmidth" -out swarm_cert.csr
# openssl x509 -req -in swarm_cert.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out swarm_cert.crt -days 365 -sha256s
lb_certificate_name        = "ociSwarmSelfSigned"
lb_ca_certificate          = "./keys/ca.crt"
lb_passphrase              = null
lb_certificate_private_key = "./keys/swarm_cert.key"
lb_public_certificate      = "./keys/swarm_cert.crt"

## Docker Swarm additional Settings

# Integrate a private OCI Repo (optional)
oci_repo_enable               = true
oci_repo_server               = "fra.ocir.io"
oci_repo_username             = "flscloud/hpcuser"
oci_repo_auth_secret          = "-YQb]STelMr7amz8CutR"
oci_repo_auth_secret_encypted = "ZmxzY2xvdWQvaHBjdXNlcjotWVFiXVNUZWxNcjdhbXo4Q3V0Ug=="

# Those Settings getting applied to the MASTER Node
# Deploy a Traefik Proxy/Loadbalancer as Ingrees Loadbalancer (optional, default is false)
traefik_enabled         = true
traefik_dashboard_fqdn  = "oci-traefik.cloud.flsmidth.com"
traefik_dashboard_login = "flsadmin:$$apr1$$ubaN3Ht4$$q6uKQvO/ivvV0AV8cX.wD." # Create a username/password: echo $(htpasswd -nb USENAME PASSWORD) | sed -e s/\\$/\\$\\$/g

# Those Settings getting applied to the MASTER Node
# Deploy a Portainer Management Tool (optional, default is false, and Traefik needs to be enabled as well (traefik_enabled = true))
portainer_enabled    = true
portainer_fqdn       = "oci-portainer.cloud.flsmidth.com"
portainer_edge_fqdn  = "oci-portainer-edge.cloud.flsmidth.com"