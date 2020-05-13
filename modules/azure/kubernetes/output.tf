output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  description = "kubectl configuration e.g: ~/.kube/config"
}
