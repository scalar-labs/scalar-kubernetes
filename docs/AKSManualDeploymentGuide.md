# How to Manually Create AKS Cluster for Scalar DL deployment

This document explains how to create an AKS cluster manually for Scalar DL.

## Create Azure Kubernetes cluster

Please follow [Create an AKS cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal#create-an-aks-cluster) with the following Scalar DL specific settings.

### Scalar DL specific settings
Select the appropriate region and resource group .
Do not forget to specify the same node pool name for `ledger` and `envoy`. The current custom config uses `scalardlpool` for that, you can modify it based on your preferences.  
The node size for `ledger` and `envoy` should be selected appropriately. The recommended node size is `Standard D2s v3`.

On the **Networking** page, configure the Kubernetes cluster in the same virtual network as the other resources: 
 - Choose `Azure CNI` as **network configuration**.
 - Kubernetes cluster deployment requires 388 addresses, specify the range in **Kubernetes service address range**

## Access AKS Cluster

Prepare kube config file
```
$ az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME>
```
