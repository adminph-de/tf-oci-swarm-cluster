# master.setup.sh and worker.setup.sh
var.oci_repo_server = "fra.ocir.io"
var.oci_repo_username = "flscloud/hpcuser"
var.oci_repo_auth_secret = "-YQb]STelMr7amz8CutR"
var.oci_repo_auth_secret_encypted = "ZmxzY2xvdWQvaHBjdXNlcjotWVFiXVNUZWxNcjdhbXo4Q3V0Ug=="
oci_swarm_region = var.region

# worker.setup.sh
 oci_swarm_master_ip     = var.master_ip