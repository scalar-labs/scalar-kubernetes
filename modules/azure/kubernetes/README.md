# Azure Kubernetes Module

The Azure Kubernetes Module creates a subnet for k8s, service principal, set permission and deploy AKS in azure with one additional node pool

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.20 |
| azuread | >= 0.8 |
| azurerm | >=2.5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| kubernetes_additional_node_pools | Custom definition kubernetes additional node pools, same as default_node_pool but for multiple dedicated node pools | `map` | `{}` | no |
| kubernetes_cluster_availability_zones | Select the available zone for the kubernetes cluster or leave empty if the datacenter does not support AZs | `list(string)` | `[]` | no |
| kubernetes_cluster | Custom definition kubernetes properties that include name of the cluster, kubernetes version, etc.. | `map` | `{}` | no |
| kubernetes_default_node_pool | Custom definition kubernetes default node pool that include number of node, node size, autoscaling, etc.. | `map` | `{}` | no |
| network | Custom definition for network and bastion | `map` | `{}` | no |

### kubernetes_cluster_properties map

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | cluster name | `string` | `scalar-kubernetes` | no |
| dns_prefix | dns prefix for the cluster | `string` | `scalar-k8s` | no |
| kubernetes_version | kubernetes version | `string` | `1.16.10` | no|
| admin_username | ssh user for node | `string` | `azureuser` | no |
| role_based_access_control | activate RBAC in k8s | `string` | `true` | no |
| kube_dashboard | activate the dashboard | `string` | `true` | no |

### kubernetes_default_node_pool map

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | name of node pool | `string` | `default` | no |
| node_count | number of node | `string` | `3` | no |
| vm_size | azure vm type | `string` | `Standard_DS2_v2` | no |
| max_pods | number max of pod per node | `string` | `100` | no |
| os_disk_size_gb | disk size per node | `string` | `64` | no |
| cluster_auto_scaling | activate cluster auto scaling | `string` | `true` | no |
| cluster_auto_scaling_min_count | minimum number of node| `string` | `3` | no |
| cluster_auto_scaling_max_count | max number of node | `string` | `6` | no |

### kubernetes_additional_node_pools map

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | name of node pool | `string` | `scalardl` | no |
| node_count | number of node | `string` | `3` | no |
| vm_size | azure vm type | `string`| `Standard_DS2_v2` | no |
| max_pods | number max of pod per node | `string` | `100` | no |
| os_disk_size_gb | disk size per node | `string` | `64` | no |
| taints | apply a toleration on the node pool | `string` | `kubernetes.io/app=scalardl:NoSchedule` | no |
| cluster_auto_scaling | activate cluster auto scaling | `string` | `true` | no |
| cluster_auto_scaling_min_count | minimum number of node| `string` | `3` | no |
| cluster_auto_scaling_max_count | max number of node | `string` | `6` | no |

## Outputs

| Name | Description |
|------|-------------|
| k8s_ssh_config |The configuration file for K8s API local port forward and SSH K8s Nodes access. |
| kube_config | kubectl configuration e.g: ~/.kube/config |
