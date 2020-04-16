## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "aks" {
  name                            = local.kubernetes_global.name
  resource_group_name             = local.kubernetes_global.resource_group_name
  location                        = local.kubernetes_global.location
  dns_prefix                      = local.kubernetes_global.dns_prefix
  kubernetes_version              = local.kubernetes_global.kubernetes_version
  api_server_authorized_ip_ranges = local.kubernetes_global.api_server_authorized_ip_ranges

  linux_profile {
    admin_username = local.kubernetes_global.admin_username
    ssh_key {
      key_data = file(local.kubernetes_global.public_ssh_key_path)
    }
  }

  default_node_pool {
    name                  = substr(local.kubernetes_default_node_pool.name, 0, 12)
    node_count            = local.kubernetes_default_node_pool.node_count
    vm_size               = local.kubernetes_default_node_pool.vm_size
    availability_zones    = local.kubernetes_default_node_pool.availability_zones
    max_pods              = local.kubernetes_default_node_pool.max_pods
    os_disk_size_gb       = local.kubernetes_default_node_pool.os_disk_size_gb
    vnet_subnet_id        = local.kubernetes_default_node_pool.vnet_subnet_id
    node_taints           = []
    enable_node_public_ip = "false"
    enable_auto_scaling   = local.kubernetes_default_node_pool.cluster_auto_scaling
    min_count             = local.kubernetes_default_node_pool.cluster_auto_scaling_min_count
    max_count             = local.kubernetes_default_node_pool.cluster_auto_scaling_max_count
  }

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
      default_node_pool,
      windows_profile
    ]
  }
}

# add one or more kubernetes node pool
resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  for_each = local.kubernetes_additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = substr(each.key, 0, 12)
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  availability_zones    = each.value.availability_zones
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_type               = each.value.node_os
  vnet_subnet_id        = each.value.vnet_subnet_id
  node_taints           = each.value.taints
  enable_node_public_ip = "false"
  enable_auto_scaling   = each.value.cluster_auto_scaling
  min_count             = each.value.cluster_auto_scaling_min_count
  max_count             = each.value.cluster_auto_scaling_max_count
}
