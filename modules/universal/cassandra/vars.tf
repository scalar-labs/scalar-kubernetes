variable "bastion_host_ip" {
  description = "The Public IP address to the Bastion Host"
}

variable "private_key_path" {
  description = "The path to a private key (.pem) file for auth"
}

variable "user_name" {
  description = "The user of the remote instance to provision"
}

variable "use_agent" {
  description = "Use ssh-agent for authentication when logging in through the bastion node."
  default     = "true"
}

variable "triggers" {
  description = "A trigger to initiate provisioning"
  default     = []
}

variable "vm_ids" {
  default = []
}

variable "host_list" {
  default     = []
  description = "A list of C* hosts (IP or DNS) to provision"
}

variable "host_seed_list" {
  default     = []
  description = "A list of C* seed hosts (IP)"
}

variable "memtable_threshold" {
  default     = "0.33"
  description = "Set C* host with custom memtable threshold limit"
}

variable "cassy_public_key" {
  default = ""
}

variable "provision_count" {
  description = "The number of bastion resources to provision"
}

variable "enable_tdagent" {
  default     = true
  description = "A flag to install td-agent that forwards logs to the monitor host"
}

variable "start_on_initial_boot" {
  default = false
}

variable "internal_domain" {
  default     = "internal.scalar-labs.com"
  description = "The internal domain"
}
