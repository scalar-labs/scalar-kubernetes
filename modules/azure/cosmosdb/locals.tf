locals {
  network = {
    name   = data.terraform_remote_state.network.outputs.network_name
    region = data.terraform_remote_state.network.outputs.region
  }

  kubernetes = {
    node_pool_subnet_id = data.terraform_remote_state.kubernetes.outputs.node_pool_subnet_id
  }
}
