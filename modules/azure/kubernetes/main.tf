module "kubernetes" {
  source = "git::https://github.com/scalar-labs/scalar-terraform.git//modules/azure/kubernetes?ref=master"

  # Required variables (use network remote state)
  network = local.network

  # Optional variables
  kubernetes_cluster               = var.kubernetes_cluster
  kubernetes_default_node_pool     = var.kubernetes_default_node_pool
  kubernetes_scalar_apps_pool      = var.kubernetes_scalar_apps_pool
  enable_cosmosdb_service_endpoint = var.enable_cosmosdb_service_endpoint
  custom_tags                      = var.custom_tags
}
