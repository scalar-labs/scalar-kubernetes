output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  description = "kubectl configuration e.g: ~/.kube/config"
}

output "k8s_ssh_config" {
  value       = <<EOF
Host *
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no

Host bastion
  HostName ${var.network.bastion_ip}
  User ${var.network.user_name}
  LocalForward 8000 monitor.${var.network.internal_domain}:80
  LocalForward 7000 ${replace(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host, "https://", "")}

Host *.${var.network.internal_domain}
  ProxyCommand ssh -F ssh.cfg bastion -W %h:%p

Host 10.*
  User ${local.kubernetes_cluster.admin_username}
  ProxyCommand ssh -F ssh.cfg bastion -W %h:%p
EOF
  description = "The configuration file for SSH access for Kubernetes."
}
