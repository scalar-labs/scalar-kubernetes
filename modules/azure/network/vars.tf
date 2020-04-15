# Required Variable
variable "name" {
  description = "A short name to attach to resources"
}

variable "location" {
  description = "The Azure location to deploy environment"
}

variable "public_key_path" {
  description = "The path to a public key file ~/.ssh/key.pub"
}

variable "private_key_path" {
  description = "The path to a private key file ~/.ssh/key.pem"
}

variable "internal_domain" {
  description = "An internal DNS domain name to use for mapping IP addresses"
}

# Optional Variable
variable "network" {
  type        = map
  default     = {}
  description = "Custom definition for network and bastion"
}

variable "additional_public_keys_path" {
  description = "The path to a file that contains multiple public keys for SSH access."
}
