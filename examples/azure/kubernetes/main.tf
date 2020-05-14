module "kubernetes" {
  source = "../../../modules/azure/kubernetes"

  # Required variables (use network remote state)
  network = local.network

  # Required kubernetes variable for AZs
  kubernetes_cluster_availability_zones = var.kubernetes_cluster_availability_zones

  # Optional variables
  kubernetes_cluster_properties    = var.kubernetes_cluster_properties
  kubernetes_default_node_pool     = var.kubernetes_default_node_pool
  kubernetes_additional_node_pools = var.kubernetes_additional_node_pools
}
