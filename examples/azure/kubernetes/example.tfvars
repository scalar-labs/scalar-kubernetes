# Optional
kubernetes_cluster_properties = {
  # name                            = "scalar-kubernetes"
  # dns_prefix                      = "scalar-k8s"
  # kubernetes_version              = "1.15.10"
  # admin_username                  = "azureuser"
  # role_based_access_control       = true
  # kube_dashboard                  = true
  # api_server_authorized_ip_ranges = ["0.0.0.0/0"]
}

kubernetes_default_node_pool = {
  # name                           = "default"
  # node_count                     = 3
  # vm_size                        = "Standard_DS2_v2"
  # availability_zones             = ["1", "2", "3"]
  # max_pods                       = 100
  # os_disk_size_gb                = 64
  # cluster_auto_scaling           = true
  # cluster_auto_scaling_min_count = 3
  # cluster_auto_scaling_max_count = 6
}

kubernetes_additional_node_pools = {
  # scalardl = {
  #   node_count                     = 3
  #   vm_size                        = "Standard_DS2_v2"
  #   availability_zones             = ["1", "2", "3"]
  #   max_pods                       = 100
  #   os_disk_size_gb                = 64
  #   taints                         = ["kubernetes.io/app=scalardl:NoSchedule"]
  #   cluster_auto_scaling           = true
  #   cluster_auto_scaling_min_count = 3
  #   cluster_auto_scaling_max_count = 6
  # }
}
