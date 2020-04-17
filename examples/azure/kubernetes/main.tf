module "kubernetes" {
  source = "../../../modules/azure/kubernetes"

  # Required Variables (Use network remote state)
  network = local.network

  # Optional Variables
  service_principal                = var.service_principal
  kubernetes_global                = var.kubernetes_global
  kubernetes_default_node_pool     = var.kubernetes_default_node_pool
  kubernetes_additional_node_pools = var.kubernetes_additional_node_pools
}
