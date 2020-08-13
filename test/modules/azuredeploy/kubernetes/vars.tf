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
  description = "Select the available zone for the kubernetes cluster"
}

variable "kubernetes_default_node_pool" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes default node pool that include number of node, node size, autoscaling, etc.."
}

variable "kubernetes_scalar_apps_pool" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes scalar apps pool, same as default_node_pool"
}

variable "custom_tags" {
  type    = map
  default = {}
}
