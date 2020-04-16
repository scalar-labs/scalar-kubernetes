### General
locals {
  network_name = var.network.name
  network_dns  = var.network.dns
  network_id   = var.network.id
  network_cidr = var.network.cidr
  location     = var.network.location

  bastion_ip      = var.network.bastion_ip
  public_key_path = var.network.public_key_path
  internal_domain = var.network.internal_domain

  triggers = [var.network.bastion_provision_id]
}

### default
locals {
  kubernetes_global_default = {
    name                            = "scalar-kubernetes"
    resource_group_name             = var.network.name
    location                        = var.network.location
    dns_prefix                      = "scalar-k8s"
    kubernetes_version              = "1.15.10"
    admin_username                  = "azureuser"
    public_ssh_key_path             = var.network.public_key_path
    role_based_access_control       = true
    kube_dashboard                  = true
    client_id                       = var.client_id
    client_secret                   = var.client_secret
    network_plugin                  = "azure"
    load_balancer_sku               = "Standard"
    service_cidr                    = cidrsubnet(var.network.cidr, 6, 4)
    docker_bridge_cidr              = "172.17.0.1/16"
    dns_service_ip                  = cidrhost(cidrsubnet(var.network.cidr, 6, 4), 2)
    api_server_authorized_ip_ranges = ["${var.network.bastion_ip}/32"]
  }
}

locals {
  kubernetes_global = merge(
    local.kubernetes_global_default,
    var.kubernetes_global
  )
}

locals {
  kubernetes_node_pool = {
    name                           = "default"
    node_count                     = 1
    vm_size                        = "Standard_DS2_v2"
    availability_zones             = ["1", "2", "3"]
    max_pods                       = 100
    os_disk_size_gb                = 64
    taints                         = []
    vnet_subnet_id                 = var.network.subnet_k8s_node_pod
    cluster_auto_scaling           = true
    cluster_auto_scaling_min_count = 1
    cluster_auto_scaling_max_count = 9
  }
}

locals {
  kubernetes_default_node_pool = merge(
    local.kubernetes_node_pool,
    var.kubernetes_default_node_pool
  )
}

locals {
  additional_node_pools = {
    scalardl = {
      node_count                     = 1
      vm_size                        = "Standard_DS2_v2"
      availability_zones             = ["1", "2", "3"]
      max_pods                       = 100
      os_disk_size_gb                = 64
      node_os                        = "Linux"
      taints                         = ["kubernetes.io/app=scalardl:NoSchedule"]
      vnet_subnet_id                 = var.network.subnet_k8s_node_pod
      cluster_auto_scaling           = true
      cluster_auto_scaling_min_count = 1
      cluster_auto_scaling_max_count = 9
    }
  }
}

locals {
  kubernetes_additional_node_pools = merge(
    local.additional_node_pools,
    var.kubernetes_additional_node_pools
  )
}
