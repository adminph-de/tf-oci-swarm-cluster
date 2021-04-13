locals {

  # Oracle Cloud Access Settions
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaazkqjclyhwbcf75aveuuvhx3gv5oy54qk2whde35vtohvfplsauma" # flscloud
  user_ocid        = "ocid1.user.oc1..aaaaaaaa6gpp2yiphzrppzdyki6xem5lmyzl2jvvl6glgcv5tird65ox2iaa"
  fingerprint      = "10:cd:a7:82:4a:7e:eb:42:d0:70:49:19:f4:f8:14:83"
  private_key_path = "~/.oci/oci_api_key.flscloud.pem"
  region           = "us-ashburn-1"


  # Defaults
  # Masrer Instance Name: ${var.label_prefix}-master-${var.label_postfix}
  # Worker Instance Name: ${var.label_prefix}-worker-${count.index + 1}-${var.label_postfix}
  label_prefix        = "oc2-swarm-hpc"
  label_postfix       = "s"
  ssh_public_key      = ""
  ssh_public_key_path = "./keys/webinit_rsa.pub"
  timezone            = "UTC"
  compartment_id      = "ocid1.compartment.oc1..aaaaaaaaensqjpvvvudpci3mubpsh3k5am7ftujsngn3reh3fjgpja2h37sq" # PoC:HPC:ROCKY:Applications
  vcn_id              = "ocid1.vcn.oc1.iad.amaaaaaanilxufiaatesgwfvnmux2t5eukj5fh64uw3fe5hg7z5fb46ejbcq"
  subnet_id           = "ocid1.subnet.oc1.iad.aaaaaaaarfdqjbbtcdrecmmdmri63c6odcqfkn4x3jfnwz3ac2viclijpzjq"
  image_id            = "ocid1.image.oc1.iad.aaaaaaaanduaanydig5trp6s2pw2mn5lchwyqramyfjzezcarcdqry7yeo7a" # Region: us-ashburn-1, OS: CentOS-7-2021.03.16-0)
  shape = {
    shape            = "VM.Standard.E3.Flex",
    ocpus            = 2,
    memory           = 12,
    boot_volume_size = 50
  }

  # Integrate a provate OCI Repo (optional)
  oci_repo_enable               = true
  oci_repo_server               = "fra.ocir.io"
  oci_repo_username             = "flscloud/hpcuser"
  oci_repo_auth_secret          = "-YQb]STelMr7amz8CutR"
  oci_repo_auth_secret_encypted = "ZmxzY2xvdWQvaHBjdXNlcjotWVFiXVNUZWxNcjdhbXo4Q3V0Ug=="

  # Swarm MASTER Node
  master_compartment_id = ""
  master_vcn_id         = ""
  master_subnet_id      = ""
  master_image_id       = ""
  master_shape          = {}

  # Swarm WORKER Node(s)
  worker_enabled        = true
  worker_node_count     = 2
  worker_compartment_id = ""
  worker_vcn_id         = ""
  worker_subnet_id      = ""
  worker_image_id       = ""
  worker_shape          = {}

  # Swarm OCI Loadbalancer
  lb_enable         = true
  lb_is_private     = false
  lb_compartment_id = ""
  # if you use public Loadbalancer, be sure lb_is_private is set to false
  # and choose a VCN and Subnet that provides Public IPs. Otherwiese the deployment fails.
  lb_vcn_id                  = "ocid1.vcn.oc1.iad.amaaaaaanilxufianppjygzpznnksymz6lguuboshu6smxe46low3dx3f5vq"    # Region: us-ashburn-1,oc2-vcn-rocky-hpc-hub-s
  lb_subnet_id               = "ocid1.subnet.oc1.iad.aaaaaaaaujiza35rvufevk6jd4q26nglzw7i6dkkjkbmkf47mq6aflel5abq" # Region: us-ashburn-1,oc2-sub-rocky-hpc-hub-1-s
  lb_shape                   = "flexible"
  lb_host_name               = "oci-swarm.cloud.flsmidth.com"
  lb_certificate_name        = "ociSwarmSelfSigned"
  lb_ca_certificate          = file("./keys/ca.crt")
  lb_passphrase              = null
  lb_certificate_private_key = file("./keys/swarm_cert.key")
  lb_public_certificate      = file("./keys/swarm_cert.crt")

}

# CA Certificate
# openssl req -x509 -nodes -newkey rsa:4096 -keyout ca.key -out ca.crt -days 365

# Serive Certifiace
# openssl genrsa -out swarm_cert.key 2048
# openssl req -new -sha256 -key swarm_cert.key -subj "/C=DK/ST=Copenhagen/O=FLSmidth" -out swarm_cert.csr
# openssl x509 -req -in swarm_cert.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out swarm_cert.crt -days 500 -sha256
