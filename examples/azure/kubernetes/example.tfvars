# Required
client_secret = ""
client_id = ""

# Optional
kubernetes_global = {
  # name                = "scalar-kubernetes"
  # kubernetes_version  = "1.15.10"
  # admin_username = "ubuntu"
  # role_based_access_control = true
  # kube_dashboard = true
  # network_plugin = "azure"
  # load_balancer_sku = "Standard"
}

kubernetes_app_pool = {
  # name                = "app"
  # node_count          = 3
  # vm_size             = "Standard_DS2_v2"
  # os_disk_size_gb     = 30
  # enable_auto_scaling = true
  # min_count           = 3
  # max_count           = 6
  # availability_zones  = ["1", "2", "3"]
}

kubernetes_utility_pool = {
  # name                = "utility"
  # node_count          = 3
  # vm_size             = "Standard_DS2_v2"
  # os_disk_size_gb     = 30
  # enable_auto_scaling = true
  # min_count           = 3
  # max_count           = 6
  # availability_zones  = ["1", "2", "3"]
}
