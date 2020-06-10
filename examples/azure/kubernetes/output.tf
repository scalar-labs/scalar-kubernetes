output "kube_config" {
  value       = module.kubernetes.kube_config
  description = "kubectl configuration e.g: ~/.kube/config"
}

output "k8s_ssh_config" {
  value       = module.kubernetes.k8s_ssh_config
  description = "The configuration file for SSH access for Kubernetes."
}
