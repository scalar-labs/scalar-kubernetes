# Required
client_id     = ""
client_secret = ""

# Optional
kubernetes_global = {
  # name                            = "scalar-kubernetes"
  # dns_prefix                      = "scalar-k8s"
  # kubernetes_version              = "1.15.10"
  # admin_username                  = "azureuser"
  # role_based_access_control       = true
  # kube_dashboard                  = true
  # network_plugin                  = "azure"
  # load_balancer_sku               = "Standard"
  # api_server_authorized_ip_ranges = ["0.0.0.0/0"]
}

kubernetes_default_node_pool = {
  # name                           = "default"
  # node_count                     = 1
  # vm_size                        = "Standard_DS2_v2"
  # availability_zones             = ["1", "2", "3"]
  # max_pods                       = 100
  # os_disk_size_gb                = 64
  # taints                         = []
  # cluster_auto_scaling           = true
  # cluster_auto_scaling_min_count = 1
  # cluster_auto_scaling_max_count = 9
}

kubernetes_additional_node_pools = {
  # scalardl = {
  #   node_count                     = 1
  #   vm_size                        = "Standard_DS2_v2"
  #   availability_zones             = ["1", "2", "3"]
  #   max_pods                       = 100
  #   os_disk_size_gb                = 64
  #   node_os                        = "Linux"
  #   taints                         = ["kubernetes.io/app=scalardl:NoSchedule"]
  #   cluster_auto_scaling           = true
  #   cluster_auto_scaling_min_count = 1
  #   cluster_auto_scaling_max_count = 9
  # }
}
