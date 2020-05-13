# Create network for kubernetes cluster
resource "azurerm_subnet" "subnet" {
  for_each = local.kubernetes_global_network

  name                 = each.key
  virtual_network_name = local.network_name
  resource_group_name  = local.network_name
  address_prefixes     = [each.value]
}

# Create Service Principals
resource "azuread_application" "aks_sp" {
  name                       = "aks-${local.network_name}"
  homepage                   = "https://aks-${local.network_name}"
  identifier_uris            = ["https://aks-${local.network_name}"]
  reply_urls                 = ["https://aks-${local.network_name}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "aks_sp" {
  application_id = azuread_application.aks_sp.application_id
}

resource "random_password" "aks_sp" {
  length  = 24
  special = false
}

resource "azuread_service_principal_password" "aks_sp" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_password.aks_sp.result
  end_date             = timeadd(timestamp(), "87600h") # 10 years

  lifecycle {
    ignore_changes = [
      end_date,
      value
    ]
  }
}

# Retrieve scope id for assignment 
data "azurerm_subscription" "current" {
}

# Set assignment Contributor to SP
resource "azurerm_role_assignment" "aks_sp_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks_sp.id

  depends_on = [
    azuread_service_principal_password.aks_sp
  ]
}

# AKS kubernetes cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                            = local.kubernetes_cluster_properties.name
  resource_group_name             = local.kubernetes_cluster_properties.resource_group_name
  location                        = local.kubernetes_cluster_properties.location
  dns_prefix                      = local.kubernetes_cluster_properties.dns_prefix
  kubernetes_version              = local.kubernetes_cluster_properties.kubernetes_version
  api_server_authorized_ip_ranges = local.kubernetes_cluster_properties.api_server_authorized_ip_ranges

  linux_profile {
    admin_username = local.kubernetes_cluster_properties.admin_username
    ssh_key {
      key_data = file(local.kubernetes_cluster_properties.public_ssh_key_path)
    }
  }

  default_node_pool {
    name                  = substr(local.kubernetes_default_node_pool.name, 0, 12)
    node_count            = local.kubernetes_default_node_pool.node_count
    vm_size               = local.kubernetes_default_node_pool.vm_size
    availability_zones    = local.kubernetes_default_node_pool.availability_zones
    max_pods              = local.kubernetes_default_node_pool.max_pods
    os_disk_size_gb       = local.kubernetes_default_node_pool.os_disk_size_gb
    vnet_subnet_id        = azurerm_subnet.subnet["k8s_node_pod"].id
    enable_node_public_ip = "false"
    enable_auto_scaling   = local.kubernetes_default_node_pool.cluster_auto_scaling
    min_count             = local.kubernetes_default_node_pool.cluster_auto_scaling_min_count
    max_count             = local.kubernetes_default_node_pool.cluster_auto_scaling_max_count
  }

  role_based_access_control {
    enabled = local.kubernetes_cluster_properties.role_based_access_control
  }

  addon_profile {
    kube_dashboard {
      enabled = local.kubernetes_cluster_properties.kube_dashboard
    }
  }

  service_principal {
    client_id     = azuread_service_principal.aks_sp.application_id
    client_secret = azuread_service_principal_password.aks_sp.value
  }

  network_profile {
    network_plugin     = local.kubernetes_cluster_properties.network_plugin
    load_balancer_sku  = local.kubernetes_cluster_properties.load_balancer_sku
    service_cidr       = local.kubernetes_cluster_properties.service_cidr
    docker_bridge_cidr = local.kubernetes_cluster_properties.docker_bridge_cidr
    dns_service_ip     = local.kubernetes_cluster_properties.dns_service_ip
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      windows_profile
    ]
  }

  depends_on = [
    azurerm_subnet.subnet,
    azurerm_role_assignment.aks_sp_role_assignment,
    azuread_service_principal_password.aks_sp
  ]
}

# Add one or more kubernetes node pool
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
  vnet_subnet_id        = azurerm_subnet.subnet["k8s_node_pod"].id
  node_taints           = each.value.taints
  enable_node_public_ip = "false"
  enable_auto_scaling   = each.value.cluster_auto_scaling
  min_count             = each.value.cluster_auto_scaling_min_count
  max_count             = each.value.cluster_auto_scaling_max_count

  depends_on = [
    azurerm_subnet.subnet,
  ]
}

# Set Network Contributor permission to service principal for network
resource "azurerm_role_assignment" "aks_subnet_node_pod" {
  scope                            = azurerm_subnet.subnet["k8s_node_pod"].id
  role_definition_name             = "Network Contributor"
  principal_id                     = azuread_service_principal.aks_sp.application_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_subnet_ingress" {
  scope                            = azurerm_subnet.subnet["k8s_ingress"].id
  role_definition_name             = "Network Contributor"
  principal_id                     = azuread_service_principal.aks_sp.application_id
  skip_service_principal_aad_check = true
}
