module "kubernetes" {
  source = "../../../modules/azure/kubernetes"

  # Required Service Principal
  client_id     = var.client_id
  client_secret = var.client_secret

  # Required Variables (Use network remote state)
  network = local.network

  # Optional Variables
  kubernetes_global                = var.kubernetes_global
  kubernetes_default_node_pool     = var.kubernetes_default_node_pool
  kubernetes_additional_node_pools = var.kubernetes_additional_node_pools
}
