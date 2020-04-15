### default
locals {
  network_default = {
    bastion_resource_type     = "Standard_D2s_v3"
    bastion_resource_count    = 1
    bastion_access_cidr       = "0.0.0.0/0"
    resource_root_volume_size = 16
    bastion_enable_tdagent    = true
    user_name                 = "centos"
    cidr                      = "10.42.0.0/16"
    image_id                  = "CentOS"
  }

  network = merge(
    local.network_default,
    var.network
  )
}

locals {
  subnet = {
    public       = cidrsubnet(local.network.cidr, 6, 0)
    k8s_node_pod = cidrsubnet(local.network.cidr, 6, 1)
    cassandra    = cidrsubnet(local.network.cidr, 6, 2)
    k8s_ingress  = cidrsubnet(local.network.cidr, 6, 3)
  }
}
