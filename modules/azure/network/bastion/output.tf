output "bastion_host_ids" {
  value       = module.bastion_cluster.vm_ids
  description = "A list of bastion hosts' IDs."
}

output "bastion_host_ips" {
  value       = module.bastion_cluster.public_ip_address
  description = "A list of bastion hosts' IP addresses."
}

output "bastion_security_group_id" {
  value       = module.bastion_cluster.network_security_group_id
  description = "The security group ID of the bastion resource."
}

output "bastion_provision_id" {
  value       = module.bastion_provision.provision_id
  description = "The provision id of bastion."
}
