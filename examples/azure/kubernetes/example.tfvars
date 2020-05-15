# Required
kubernetes_cluster_availability_zones = ["1", "2", "3"]

# Optional
kubernetes_cluster = {
  # name                            = "scalar-kubernetes"
  # dns_prefix                      = "scalar-kubernetes"
  # kubernetes_version              = "1.15.10"
  # admin_username                  = "azureuser"
  # role_based_access_control       = true
  # kube_dashboard                  = true
}

kubernetes_default_node_pool = {
  # name                           = "default"
  # node_count                     = "3"
  # vm_size                        = "Standard_D2s_v3"
  # max_pods                       = "100"
  # os_disk_size_gb                = "64"
  # cluster_auto_scaling           = "true"
  # cluster_auto_scaling_min_count = "3"
  # cluster_auto_scaling_max_count = "6"
}

kubernetes_additional_node_pools = {
  # name                           = scalardl
  # node_count                     = "3"
  # vm_size                        = "Standard_D2s_v3"
  # max_pods                       = "100"
  # os_disk_size_gb                = "64"
  # taints                         = "kubernetes.io/app=scalardl:NoSchedule"
  # cluster_auto_scaling           = "true"
  # cluster_auto_scaling_min_count = "3"
  # cluster_auto_scaling_max_count = "6"
}
