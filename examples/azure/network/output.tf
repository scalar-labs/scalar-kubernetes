output "bastion_ip" {
  value = module.network.bastion_ip
}

output "network_cidr" {
  value = module.network.network_cidr
}

output "network_name" {
  value = module.network.network_name
}

output "dns_zone_id" {
  value = module.network.dns_zone_id
}

output "network_id" {
  value = module.network.network_id
}

output "subnet_map" {
  value = module.network.subnet_map
}

output "image_id" {
  value = module.network.image_id
}

output "bastion_provision_id" {
  value = module.network.bastion_provision_id
}

output "public_key_path" {
  value = module.network.public_key_path
}

output "location" {
  value = module.network.location
}

output "user_name" {
  value = module.network.user_name
}

output "private_key_path" {
  value = module.network.private_key_path
}

output "ssh_config" {
  value = module.network.ssh_config
}

output "internal_domain" {
  value = module.network.internal_domain
}
