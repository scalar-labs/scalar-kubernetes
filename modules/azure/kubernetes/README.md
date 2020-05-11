# Azure Kubernetes Module
The Azure Kubernetes Module creates a subnet for k8s, service principal, set permission and deploy AKS in azure with one additional node pool

## Providers

| Name | Version |
|------|---------|
| azurerm | >=2.5.0 |
| azuread | >= 0.8 |

## Inputs

### kubernetes_global map

| Name | Description | Type | Default | Required |
|------|:-----:|------|---------|:-----:|
| name | cluster name | strings | scalar-kubernetes | no |
| dns_prefix | dns prefix for the cluster | strings | scalar-k8s | no |
| kubernetes_version | kubernetes version | strings | 1.15.10 | no|
| admin_username | ssh user for node | strings | azureuser | no |
| role_based_access_control | activate RBAC in k8s | bool | true | no |
| kube_dashboard | activate the dashboard | bool | true | no |
| api_server_authorized_ip_ranges | list of ip who can have access to k8s api | list | bastion CDIR range | no |

### kubernetes_default_node_pool map

| Name | Description | Type | Default | Required |
|------|:-------------:|------|---------|:-----:|
| name | name of node pool | strings | default | no |
| node_count | number of node | int | 1 | no |
| vm_size | azure vm type | strings| Standard_DS2_v2 | no |
| availability_zones | select the available zone | list | ["1", "2", "3"] | no |
| max_pods | number max of pod per node | int | 100 | no |
| os_disk_size_gb | disk size per node | int | 64 | no |
| cluster_auto_scaling | activate cluster auto scaling | bool | true | no |
| cluster_auto_scaling_min_count | minimum number of node| int | 1 | no |
| cluster_auto_scaling_max_count | max number of node | int | 9 | no |

### kubernetes_additional_node_pools map

Please be careful kubernetes_additional_node_pools is a map with key. the key represent the name of the node pool.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| key | name of node pool | strings | scalardl | no |
| node_count | number of node | int | 1 | no |
| vm_size | azure vm type | strings| Standard_DS2_v2 | no |
| availability_zones | select the available zone | list | ["1", "2", "3"] | no |
| max_pods | number max of pod per node | int | 100 | no |
| os_disk_size_gb | disk size per node | int | 64 | no |
| taints | apply a toleration on the node pool | list | ["kubernetes.io/app=scalardl:NoSchedule"] | no |
| cluster_auto_scaling | activate cluster auto scaling | bool | true | no |
| cluster_auto_scaling_min_count | minimum number of node| int | 1 | no |
| cluster_auto_scaling_max_count | max number of node | int | 9 | no |

## Outputs

| Name | Description |
|------|-------------|
| kube_config | kubectl configuration e.g: ~/.kube/config |
