locals {
  network = {
    name      = data.terraform_remote_state.network.outputs.network_name
    dns       = data.terraform_remote_state.network.outputs.dns_zone_id
    id        = data.terraform_remote_state.network.outputs.network_id
    region    = data.terraform_remote_state.network.outputs.region
    cidr      = data.terraform_remote_state.network.outputs.network_cidr
    locations = join(",", data.terraform_remote_state.network.outputs.locations)

    bastion_ip = data.terraform_remote_state.network.outputs.bastion_ip
    user_name  = data.terraform_remote_state.network.outputs.user_name

    public_key_path = data.terraform_remote_state.network.outputs.public_key_path
    internal_domain = data.terraform_remote_state.network.outputs.internal_domain
  }
}
