locals {
  network = {
    name     = data.terraform_remote_state.network.outputs.network_name
    dns      = data.terraform_remote_state.network.outputs.dns_zone_id
    id       = data.terraform_remote_state.network.outputs.network_id
    location = data.terraform_remote_state.network.outputs.location
    cidr     = data.terraform_remote_state.network.outputs.network_cidr

    public_key_path = data.terraform_remote_state.network.outputs.public_key_path
    internal_domain = data.terraform_remote_state.network.outputs.internal_domain
  }
}
