## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.kubernetes_global.name
  resource_group_name = local.kubernetes_global.resource_group_name
  location            = local.kubernetes_global.location
  dns_prefix          = local.kubernetes_global.dns_prefix
  kubernetes_version  = local.kubernetes_global.kubernetes_version

  linux_profile {
    admin_username = local.kubernetes_global.admin_username
    ssh_key {
      key_data = file(local.kubernetes_global.public_ssh_key_path)
    }
  }

  default_node_pool {
    name                = local.kubernetes_app_pool.name
    node_count          = local.kubernetes_app_pool.node_count
    vm_size             = local.kubernetes_app_pool.vm_size
    os_disk_size_gb     = local.kubernetes_app_pool.os_disk_size_gb
    vnet_subnet_id      = local.kubernetes_app_pool.vnet_subnet_id
    enable_auto_scaling = local.kubernetes_app_pool.enable_auto_scaling
    min_count           = local.kubernetes_app_pool.min_count
    max_count           = local.kubernetes_app_pool.max_count
    availability_zones  = local.kubernetes_app_pool.availability_zones
  }

  # use azurerm_kubernetes_cluster_node_pool
  # default_node_pool {
  #   name                = local.kubernetes_utility_pool.name
  #   node_count          = local.kubernetes_utility_pool.node_count
  #   vm_size             = local.kubernetes_utility_pool.vm_size
  #   os_disk_size_gb     = local.kubernetes_utility_pool.os_disk_size_gb
  #   vnet_subnet_id      = local.kubernetes_utility_pool.vnet_subnet_id
  #   enable_auto_scaling = local.kubernetes_utility_pool.enable_auto_scaling
  #   min_count           = local.kubernetes_utility_pool.min_count
  #   max_count           = local.kubernetes_utility_pool.max_count
  #   availability_zones  = local.kubernetes_utility_pool.availability_zones
  # }

  role_based_access_control {
    enabled = local.kubernetes_global.role_based_access_control
  }

  addon_profile {
    kube_dashboard {
      enabled = local.kubernetes_global.kube_dashboard
    }
  }

  service_principal {
    client_id     = local.kubernetes_global.client_id
    client_secret = local.kubernetes_global.client_secret
  }

  network_profile {
    # use Azure CNI to allow connection to cassandra
    network_plugin     = local.kubernetes_global.network_plugin
    load_balancer_sku  = local.kubernetes_global.load_balancer_sku
    service_cidr       = local.kubernetes_global.service_cidr
    docker_bridge_cidr = local.kubernetes_global.docker_bridge_cidr
    dns_service_ip     = local.kubernetes_global.dns_service_ip
  }

  lifecycle {
    ignore_changes = [
      default_node_pool
    ]
  }
}