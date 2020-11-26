# How to Manually Create AKS Cluster for Scalar DL deployment

This document explains how to create an AKS cluster manually for Scalar DL.

## Create Azure Kubernetes cluster

Please follow [Create an AKS cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal#create-an-aks-cluster) with the following Scalar DL specific settings.

### Scalar DL specific settings
Please select the region and the resource group appropriately for your system.
Also, please specify the same node pool name for `ledger` and `envoy`. It will help you to deploy them in the same node pool. The current custom config specifies `scalardlpool` for that, so please specify it if you don't have any preference.
Accordingly, the node size for `ledger` and `envoy` should be selected appropriately. The recommended node size is `Standard D2s v3` if you don't have any preference.

On the **Networking** page, configure the Kubernetes cluster in the same virtual network as the other resources, so please choose `Azure CNI` as **network configuration**.
Kubernetes cluster deployment requires 388 addresses so please create a subnet accordingly.

## Access AKS Cluster

Prepare kube config file
```
$ az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME>
```
