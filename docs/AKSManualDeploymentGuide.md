# How to Manually Create AKS Cluster for Scalar DL deployment.

This document explains how to create an AKS cluster manually for Scalar DL.

Here we assume the scalar-terraform network environment is properly created, If you haven't done it, please create it first by following [this](https://github.com/scalar-labs/scalar-terraform/blob/master/examples/azure/README.md#create-network-resources).

## Create Azure Kubernetes cluster

This section explains how to set up Azure Kubernetes cluster with the Azure portal.

Please follow to [Create an AKS cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal#create-an-aks-cluster) with Scalar DL Requirements. 

### Scalar DL Requirements

Page    |Fields  |Default Value  |Remarks    |
--------|--------|---------------|---------------|
Basics  |Resource group|     |Should use resource group created by scalar-terraform  |
Basics  |Region  |   |Should select the same region as of scalar-terraform  |
Basics  |Node size   |Standard D2s v3    |You can choose node size based on requirements    |
Basics  |Node count  |3  |You can change based on requirements   |
Node pools  |Node pool name  |scalardlpool   |Should change `agentpool (primary)` to `scalardlpool` by clicking on `agentpool (primary)` link |
Node pools  |Max pods per node   |100    |You can change max pods per node based on your requirements    |
Networking  |Network configuration   |Azure CNI  | Should use network configuration type as `Azure CNI` |
Networking  |Virtual network    |   |Should select Vnet created by scalar-terraform  |
Networking  |Subnet |   |Should create and select a new subnet with more than 338 address such as `10.42.44.0/22` in Vnet created by scalar-terraform.    |

## Access AKS Cluster

Prepare kube config file
```
$ az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME>
```
