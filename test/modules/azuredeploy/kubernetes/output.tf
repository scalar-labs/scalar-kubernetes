output "kube_config" {
  value       = module.kubernetes.kube_config
  description = "kubectl configuration e.g: ~/.kube/config"
}
