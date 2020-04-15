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
    name                      = "scalar-kubernetes"
    resource_group_name       = var.network.name
    location                  = var.network.location
    dns_prefix                = "scalar-k8s"
    kubernetes_version        = "1.15.10"
    admin_username            = "ubuntu"
    public_ssh_key_path       = var.network.public_key_path
    role_based_access_control = true
    kube_dashboard            = true
    client_id                 = var.client_id
    client_secret             = var.client_secret
    network_plugin            = "azure"
    load_balancer_sku         = "Standard"
    service_cidr              = cidrsubnet(var.network.cidr, 6, 4)
    docker_bridge_cidr        = "172.17.0.1/16"
    dns_service_ip            = cidrhost(cidrsubnet(var.network.cidr, 6, 4), 2)
  }
}

locals {
  kubernetes_global = merge(
    local.kubernetes_global_default,
    var.kubernetes_global
  )
}

locals {
  kubernetes_app_pool_default = {
    name                = "app"
    node_count          = 3
    vm_size             = "Standard_DS2_v2"
    os_disk_size_gb     = 30
    vnet_subnet_id      = var.network.subnet_k8s_node_pod
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 6
    availability_zones  = ["1", "2", "3"]
  }
}

locals {
  kubernetes_app_pool = merge(
    local.kubernetes_app_pool_default,
    var.kubernetes_app_pool
  )
}

locals {
  kubernetes_utility_pool_default = {
    name                = "utility"
    node_count          = 3
    vm_size             = "Standard_DS2_v2"
    os_disk_size_gb     = 30
    vnet_subnet_id      = var.network.subnet_k8s_node_pod
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 6
    availability_zones  = ["1", "2", "3"]
  }
}

locals {
  kubernetes_utility_pool = merge(
    local.kubernetes_utility_pool_default,
    var.kubernetes_utility_pool
  )
}