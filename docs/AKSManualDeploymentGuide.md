# How to Manually Create AKS Cluster for Scalar DL deployment

This document explains how to create an AKS cluster manually for Scalar DL.

## Create Azure Kubernetes cluster

Please follow [Create an AKS cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal#create-an-aks-cluster) with the following Scalar DL specific settings.

### Scalar DL specific settings
Select the appropriate region and resource group for Scalar DL environment creation. Create 2 subnets with prefix of at least `/22` for AKS, one subnet must be created with the name `k8s_ingress` to create an envoy load balancer.
If you use a different subnet for the envoy load balancer it must be specified in the custom config file.
Do not forget to specify the same node pool name for `ledger` and `envoy`. The current custom config uses `scalardlpool` for that, you can modify it based on your preferences.
The node size for `ledger` and `envoy` should be selected appropriately. The recommended node size is `Standard D2s v3`.

On the **Networking** page, configure the Kubernetes cluster in the same virtual network as the other resources: 
 - Choose `Azure CNI` as **network configuration** and select the subnet other than `k8s_ingress`.

## Access AKS Cluster

Prepare kube config file
```
$ az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME>
```

## Next steps

Once the AKS cluster is ready you can keep going by following:

- [Manual deployment guide ScalarDL on Azure](ManualDeploymentGuideScalarDLOnAzure.md).