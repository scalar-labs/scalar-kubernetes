# How to Manually Create AKS Cluster for Scalar DL deployment.

This document explains how to create an AKS cluster manually for Scalar DL.

## Create Azure Kubernetes cluster

This section explains how to set up Azure Kubernetes cluster with the Azure portal.

Please follow [Create an AKS cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal#create-an-aks-cluster) with the following Scalar DL specific settings.

### Scalar DL specific settings
Please choose the resource group and the region appropriately for your system. Ledger and envoy will be deployed in the same node so choose the appropriate node size for that.
You can choose the appropriate node count based on requirements, our recommended node count is 3 or more.

Please configure an appropriate node pool name, it will help you to deploy the ledger and envoy in the same node pool. The node pool name specified in the helm configuration file is `scalardlpool`,  
So if you are using a different node pool name you should update it in [helm configuration](../conf/scalardl-custom-values.yaml) file also. 

On the **Networking** page, configure the Kubernetes cluster in the same virtual network as the other resources, so please choose `Azure CNI` as **network configuration**. 
Kubernetes cluster deployment requires 388 addresses so please create a subnet accordingly.

## Access AKS Cluster

Prepare kube config file
```
$ az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME>
```
