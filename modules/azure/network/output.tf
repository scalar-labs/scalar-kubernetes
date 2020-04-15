output "network_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The virtual network ID."
}

output "network_name" {
  value       = azurerm_resource_group.resource_group.name
  description = "Short name to identify environment."
}

output "network_cidr" {
  value       = azurerm_virtual_network.vnet.address_space[0]
  description = "The virtual network CIDR address space."
}

output "subnet_map" {
  value = {
    public       = azurerm_subnet.subnet["public"].id
    k8s_node_pod = azurerm_subnet.subnet["k8s_node_pod"].id
    cassandra    = azurerm_subnet.subnet["cassandra"].id
    k8s_ingress  = azurerm_subnet.subnet["k8s_ingress"].id
  }
  description = "The subnet map of virtual network."
}

output "subnet_map_cidr" {
  value = {
    public       = azurerm_subnet.subnet["public"].address_prefix
    k8s_node_pod = azurerm_subnet.subnet["k8s_node_pod"].address_prefix
    cassandra    = azurerm_subnet.subnet["cassandra"].address_prefix
    k8s_ingress  = azurerm_subnet.subnet["k8s_ingress"].address_prefix
  }
  description = "The subnet cidr map  of virtual network."
}

output "image_id" {
  value       = local.network.image_id
  description = "The image id to initiate."
}

output "dns_zone_id" {
  value       = basename(azurerm_private_dns_zone.dns.id)
  description = "The virtual network DNS ID."
}

output "bastion_provision_id" {
  value       = module.bastion.bastion_provision_id
  description = "The provision id of bastion."
}

output "public_key_path" {
  value       = abspath(pathexpand(var.public_key_path))
  description = "The path to the public key for SSH access."
}

output "additional_public_keys_path" {
  value       = abspath(pathexpand(var.additional_public_keys_path))
  description = "The path to a file that contains multiple public keys for SSH access."
}

output "bastion_ip" {
  value       = module.bastion.bastion_host_ips[0]
  description = "Public IP address to bastion host"
}

output "location" {
  value       = var.location
  description = "The AWS availability zone to deploy environment."
}

output "user_name" {
  value       = local.network.user_name
  description = "The user name of the remote hosts."
}

output "private_key_path" {
  value       = abspath(pathexpand(var.private_key_path))
  description = "The path to the private key for SSH access."
}

output "internal_domain" {
  value       = var.internal_domain
  description = "The internal domain for setting srv record."
}

output "ssh_config" {
  value = <<EOF
Host *
User ${local.network.user_name}
UserKnownHostsFile /dev/null
StrictHostKeyChecking no

Host bastion
HostName ${module.bastion.bastion_host_ips[0]}
LocalForward 8000 monitor.${var.internal_domain}:80

Host *.${var.internal_domain}
ProxyCommand ssh -F ssh.cfg bastion -W %h:%p
EOF

  description = "The configuration file for SSH access."
}
