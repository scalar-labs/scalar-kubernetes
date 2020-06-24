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
  User ${var.network.user_name}
  ProxyCommand ssh -F ssh.cfg bastion -W %h:%p

Host ${regex("(^10\\.|^172\\.1[6-9]\\.|^172\\.2[0-9]\\.|^172\\.3[0-1]\\.|^192\\.168\\.)", var.network.cidr)[0]}*
  User ${local.kubernetes_cluster.admin_username}
  ProxyCommand ssh -F ssh.cfg bastion -W %h:%p
EOF
  description = "The configuration file for K8s API local port forward and SSH K8s Nodes access."
}
