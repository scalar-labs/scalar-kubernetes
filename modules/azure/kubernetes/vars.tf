variable "network" {
  type    = map
  default = {}
}

variable "client_secret" {
}

variable "client_id" {
}

variable "kubernetes_global" {
  type    = map
  default = {}
}

variable "kubernetes_app_pool" {
  type    = map
  default = {}
}

variable "kubernetes_utility_pool" {
  type    = map
  default = {}
}