variable "network" {
  type    = map
  default = {}
}

variable "kubernetes_global" {
  type    = map
  default = {}
}

variable "kubernetes_default_node_pool" {
  type    = map
  default = {}
}

variable "kubernetes_additional_node_pools" {
  type    = map
  default = {}
}
