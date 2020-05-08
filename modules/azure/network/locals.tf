
locals {
  subnet = {
    public       = cidrsubnet(local.network.cidr, 6, 0)
    k8s_node_pod = cidrsubnet(local.network.cidr, 6, 1)
    cassandra    = cidrsubnet(local.network.cidr, 6, 2)
    k8s_ingress  = cidrsubnet(local.network.cidr, 6, 3)
  }
}
