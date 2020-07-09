locals {
  network = {
    cidr     = data.terraform_remote_state.network.outputs.network_cidr
    name     = data.terraform_remote_state.network.outputs.network_name
    dns      = data.terraform_remote_state.network.outputs.dns_zone_id
    id       = data.terraform_remote_state.network.outputs.network_id
    location = data.terraform_remote_state.network.outputs.location

    subnet_id = data.terraform_remote_state.network.outputs.subnet_map["private"]
    image_id  = data.terraform_remote_state.network.outputs.image_id

    bastion_ip           = data.terraform_remote_state.network.outputs.bastion_ip
    bastion_provision_id = data.terraform_remote_state.network.outputs.bastion_provision_id

    public_key_path  = data.terraform_remote_state.network.outputs.public_key_path
    private_key_path = data.terraform_remote_state.network.outputs.private_key_path
    user_name        = data.terraform_remote_state.network.outputs.user_name
    internal_domain  = data.terraform_remote_state.network.outputs.internal_domain
  }

  cassandra = {
    resource_count = data.terraform_remote_state.cassandra.outputs.cassandra_resource_count
  }

  scalardl = {
    blue_resource_count  = data.terraform_remote_state.scalardl.outputs.scalardl_blue_resource_count
    green_resource_count = data.terraform_remote_state.scalardl.outputs.scalardl_green_resource_count
    replication_factor   = data.terraform_remote_state.scalardl.outputs.scalardl_replication_factor
  }
}
