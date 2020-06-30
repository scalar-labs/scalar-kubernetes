variable "network" {
  type        = map
  default     = {}
  description = "Custom definition for network and bastion"
}

variable "kubernetes_cluster" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes properties that include name of the cluster, kubernetes version, etc.."
}

variable "kubernetes_cluster_availability_zones" {
  type        = list(string)
  default     = []
  description = "Select the available zone for the kubernetes cluster or leave empty if the datacenter does not support AZs"
}

variable "kubernetes_default_node_pool" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes default node pool that include number of node, node size, autoscaling, etc.."
}

variable "kubernetes_additional_node_pools" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes additional node pools, same as default_node_pool"
}
