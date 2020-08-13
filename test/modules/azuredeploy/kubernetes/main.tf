module "kubernetes" {
  source = "../../../../modules/azure/kubernetes"

  # Required variables (use network remote state)
  network = local.network

  # Required kubernetes variable for AZs
  kubernetes_cluster_availability_zones = var.kubernetes_cluster_availability_zones

  # Optional variables
  kubernetes_cluster           = var.kubernetes_cluster
  kubernetes_default_node_pool = var.kubernetes_default_node_pool
  kubernetes_scalar_apps_pool  = var.kubernetes_scalar_apps_pool
  custom_tags                  = var.custom_tags
}
