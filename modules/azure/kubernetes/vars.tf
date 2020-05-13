variable "network" {
  type        = map
  default     = {}
  description = "Custom definition for network and bastion"
}

variable "kubernetes_global" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes global that include name of the cluster, kubernetes version, etc.."
}

variable "kubernetes_default_node_pool" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes default node pool that include number of node, node size, autoscaling, etc.."
}

variable "kubernetes_additional_node_pools" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes additional node pools, same as default_node_pool but for muliple dedicated node pools"
}
