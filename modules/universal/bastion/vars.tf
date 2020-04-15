variable "bastion_host_ips" {
  description = "The Public IP address to the Bastion Host"
  default     = []
}

variable "private_key_path" {
  description = "The path to a private key (.pem) file for auth"
}

variable "user_name" {
  description = "The user of the remote instance to provision"
}

variable "triggers" {
  description = "A trigger to initiate provisioning"
  default     = []
}

variable "additional_public_keys_path" {
  description = "The path to a file that contains multiple public keys for SSH access."
}

variable "provision_count" {
  description = "The number of bastion resources to provision"
}

variable "enable_tdagent" {
  default     = true
  description = "A flag to install td-agent that forwards logs to the monitor host"
}

variable "internal_domain" {
  default     = "internal.scalar-labs.com"
  description = "The internal domain"
}
