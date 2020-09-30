output "node_pool_subnet_id" {
  value = module.kubernetes.node_pool_subnet_id
}

output "kube_config" {
  value       = module.kubernetes.kube_config
  description = "kubectl configuration e.g: ~/.kube/config"
}

output "k8s_ssh_config" {
  value       = module.kubernetes.k8s_ssh_config
  description = "The configuration file for K8s API local port forward and SSH K8s Nodes access."
}

output "inventory_ini" {
  value = <<EOF
[bastion]
${local.network.bastion_ip}

[bastion:vars]
ansible_user=${local.network.user_name}
ansible_python_interpreter=/usr/bin/python3

[all:vars]
internal_domain=${local.network.internal_domain}
EOF
}
