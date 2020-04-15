locals {
  network = {
    name     = data.terraform_remote_state.network.outputs.network_name
    dns      = data.terraform_remote_state.network.outputs.dns_zone_id
    id       = data.terraform_remote_state.network.outputs.network_id
    location = data.terraform_remote_state.network.outputs.location
    cidr     = data.terraform_remote_state.network.outputs.network_cidr

    # subnet_k8s_service  = data.terraform_remote_state.network.outputs.subnet_map["k8s_service"]
    subnet_k8s_ingress  = data.terraform_remote_state.network.outputs.subnet_map["k8s_ingress"]
    subnet_k8s_node_pod = data.terraform_remote_state.network.outputs.subnet_map["k8s_node_pod"]

    # subnet_k8s_service_cidr  = data.terraform_remote_state.network.outputs.subnet_map_cidr["k8s_service"]
    subnet_k8s_ingress_cidr  = data.terraform_remote_state.network.outputs.subnet_map_cidr["k8s_ingress"]
    subnet_k8s_node_pod_cidr = data.terraform_remote_state.network.outputs.subnet_map_cidr["k8s_node_pod"]

    bastion_ip           = data.terraform_remote_state.network.outputs.bastion_ip
    bastion_provision_id = data.terraform_remote_state.network.outputs.bastion_provision_id

    public_key_path = data.terraform_remote_state.network.outputs.public_key_path
    internal_domain = data.terraform_remote_state.network.outputs.internal_domain
  }
}
