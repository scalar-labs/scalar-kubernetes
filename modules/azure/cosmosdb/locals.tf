locals {
  network = {
    cidr   = data.terraform_remote_state.network.outputs.network_cidr
    name   = data.terraform_remote_state.network.outputs.network_name
    dns    = data.terraform_remote_state.network.outputs.dns_zone_id
    id     = data.terraform_remote_state.network.outputs.network_id
    region = data.terraform_remote_state.network.outputs.region

    bastion_ip           = data.terraform_remote_state.network.outputs.bastion_ip
    bastion_provision_id = data.terraform_remote_state.network.outputs.bastion_provision_id

    internal_domain = data.terraform_remote_state.network.outputs.internal_domain
  }

  kubernetes = {
    node_pool_subnet_id = data.terraform_remote_state.kubernetes.outputs.node_pool_subnet_id
  }
}
