# General Settings
variable "name" {}

variable "location" {}

variable "public_key_path" {}

variable "private_key_path" {}

variable "additional_public_keys_path" {
  default = "./additional_public_keys"
}

variable "internal_domain" {}

variable "network" {
  type    = map
  default = {}
}
