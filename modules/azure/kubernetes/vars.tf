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

variable "kubernetes_default_node_pool" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes default node pool that include number of node, node size, autoscaling, etc.."
}

variable "kubernetes_scalar_apps_pool" {
  type        = map
  default     = {}
  description = "Custom definition kubernetes scalar apps node pools, same as default_node_pool"
}

variable "use_cosmosdb" {
  type        = bool
  default     = false
  description = "Whether to use Cosmos DB. If true, a service endpoint for Cosmos DB is enabled."
}

variable "custom_tags" {
  type    = map
  default = {}
}
