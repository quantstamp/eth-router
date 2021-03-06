provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.shared_credentials_profile}"
}

/* Creates a VPC, shared subnet, and gateway */
module "network" {
  source = "./modules/network"
  working_environment = "${var.working_environment}"
}

terraform {
  backend "s3" {
    bucket = "prod-rpc-terraform-state"
    key    = "data/files"
    region = "us-west-2"
  }
}

module "proxy" {
  source        = "./modules/proxy"
  key_name      = "${var.rpc_proxy_key_name}" 
  region        = "${var.region}"
  dns_name      = "${var.dns_name}"
  vpc_id        = "${module.network.vpc_id}"
  subnet_id     = "${module.network.subnet_id}"
  instance_type = "t2.medium"
  working_environment = "${var.working_environment}"
  #amis          = "${var.ami_map}"
}


module "blockchain" {
  source        = "./modules/blockchain"
  key_name      = "${var.blockchain_key_name}" 
  region        = "${var.region}"
  vpc_id        = "${module.network.vpc_id}"
  subnet_id     = "${module.network.subnet_id}"
  instance_type = "r5.xlarge" # this is quite large, consider lowering if you only run a testnet
  num_nodes     = "${var.num_blockchain_nodes}"
  working_environment = "${var.working_environment}"
  #amis          = "${var.ami_map}"
}

resource "null_resource" "geth_munin_plugins" {
  # Stages the geth munin plugins for Ansible
  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible/roles/blockchain/files/"
    command     = "cp ${path.module}/../../munin_plugins/eth/*.py ."
  }
}

# might want a local-exec for this at some point: 
# ssh-keyscan -H {{ inventory_hostname }} >> ~/.ssh/known_hosts

/* Run the Ansible playbook for the blockchain node(s) 
resource "null_resource" "ansible_configure_blockchain" {
  depends_on = [
    "local_file.ansible_hosts"
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"
    command = "ansible-playbook --vault-password-file ${path.module}/dump_to_txt.sh -i hosts -u ubuntu blockchain.yml -e \"proxy_hostname=${var.dns_name} data_disk=${module.blockchain.chain_data_volume}\""
  }
}
*/

resource "null_resource" "prod_tokens" {
  # Stages the prod tokens file for Ansible
  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible/roles/ethrouter/files/"
    command     = "cp ${path.module}/../../src/config/tokens/production.json ."
  }
}

/* Run the Ansible playbook for the proxy node(s) 
resource "null_resource" "ansible_configure_proxy" {
  depends_on = [
    "local_file.ansible_hosts",
    "null_resource.prod_tokens",
    "modules.proxy.aws_eip_association.eip_assoc"
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"
    command = "ansible-playbook --vault-password-file ${path.module}/dump_to_txt.sh -i hosts -u ubuntu proxy.yml -e \"ssl_hostname=${var.dns_name}\""
  }
}
*/
