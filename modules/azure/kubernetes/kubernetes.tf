# Create Service Principals
resource "random_password" "aks" {
  length  = 20
  special = true
}

resource "azuread_application" "aks" {
  count = length(var.service_principal) == 2 ? 1 : 0
  name = var.network.name
}

resource "azuread_service_principal" "aks" {
  count = length(var.service_principal) == 2 ? 1 : 0
  application_id = azuread_application.aks[0].application_id
}

resource "azuread_service_principal_password" "aks" {
  count = length(var.service_principal) == 2 ? 1 : 0
  service_principal_id = azuread_service_principal.aks[0].id
  value                = random_password.aks.result
  end_date_relative    = "8760h"
}

# AKS kubernetes cluster #
resource "azurerm_kubernetes_cluster" "aks" {
  name                            = local.kubernetes_global.name
  resource_group_name             = local.kubernetes_global.resource_group_name
  location                        = local.kubernetes_global.location
  dns_prefix                      = local.kubernetes_global.dns_prefix
  kubernetes_version              = local.kubernetes_global.kubernetes_version
  api_server_authorized_ip_ranges = [
    "${local.kubernetes_global.api_server_authorized_ip_ranges == "" ? local.kubernetes_global.api_server_authorized_ip_ranges : "0.0.0.0/0"}"
  ]

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
    client_id = lookup(var.service_principal, "client_id", azuread_service_principal.aks[0].application_id)
    client_secret = lookup(var.service_principal, "client_secret", azuread_service_principal_password.aks[0].value)
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
      default_node_pool[0].node_count,
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

# Set Network Contributor permission to service principal
resource "azurerm_role_assignment" "aks_subnet_node_pod" {
  scope                = local.kubernetes_default_node_pool.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = lookup(var.service_principal, "client_id", azuread_service_principal.aks[0].application_id)
}

resource "azurerm_role_assignment" "aks_subnet_ingress" {
  scope                = var.network.subnet_k8s_ingress
  role_definition_name = "Network Contributor"
  principal_id         = lookup(var.service_principal, "client_id", azuread_service_principal.aks[0].application_id)
}
