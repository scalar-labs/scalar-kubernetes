# Guidelines for creating an AKS cluster for ScalarDL Ledger

This document explains the requirements and recommendations for creating an Azure Kubernetes Service (AKS) cluster for ScalarDL Ledger deployment. For details on how to deploy ScalarDL Ledger on an AKS cluster, see [Deploy ScalarDL Ledger on AKS](./ManualDeploymentGuideScalarDLOnAKS.md).

## Before you begin

You must create an AKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an AKS cluster, refer to the following official Microsoft documentation based on the tool you use in your environment:

* [Azure CLI](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli)
* [PowerShell](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-powershell)
* [Azure portal](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal)

## Requirements

When deploying ScalarDL Ledger, you must:

* Create the AKS cluster by using Kubernetes version 1.21 or higher.
* Configure the AKS cluster based on the version of Kubernetes and your project's requirements.

{% capture notice--warning %}
**Attention**

For Byzantine fault detection in ScalarDL to work properly, do not deploy your application pods on the same AKS cluster as the ScalarDL Ledger deployment.
{% endcapture %}

<div class="notice--warning">{{ notice--warning | markdownify }}</div>

## Recommendations (optional)

The following are some recommendations for deploying ScalarDL Ledger. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Create at least three worker nodes and three pods

To ensure that the AKS cluster has high availability, you should use at least three worker nodes and deploy at least three pods spread across the worker nodes. You can see the [sample configurations](../conf/scalardl-custom-values.yaml) of `podAntiAffinity` for making three pods spread across the worker nodes.

{% capture notice--info %}
**Note**

If you place the worker nodes in different [availability zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview) (AZs), you can withstand an AZ failure.
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger node pool

From the perspective of commercial licenses, resources for one pod running ScalarDL Ledger are limited to 2vCPU / 4GB memory. In addition to the ScalarDL Ledger pod, Kubernetes could deploy some of the following components to each worker node:

* ScalarDL Ledger pod (2vCPU / 4GB)
* Envoy proxy
* Monitoring components (if you deploy monitoring components such as `kube-prometheus-stack`)
* Kubernetes components

With this in mind, you should use a worker node that has at least 4vCPU / 8GB memory resources and use at least three worker nodes for availability, as mentioned in [Create at least three worker nodes and three pods](#create-at-least-three-worker-nodes-and-three-pods).

However, three nodes with at least 4vCPU / 8GB memory resources per node is the minimum environment for production. You should also consider the resources of the AKS cluster (for example, the number of worker nodes, vCPUs per node, memory per node, and ScalarDL Ledger pods), which depend on your system's workload. In addition, if you plan to scale the pods automatically by using some features like [Horizontal Pod Autoscaling (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), you should consider the maximum number of pods on the worker node when deciding the worker node resources.

### Create a node pool for ScalarDL Ledger pods

AKS creates one system node pool named **agentpool** that is preferred for system pods (used to keep AKS running) by default. We recommend creating another node pool with **user** mode for ScalarDL Ledger pods and deploying ScalarDL Ledger pods on this additional node pool.

### Configure cluster autoscaler in AKS

If you want to scale ScalarDL Ledger pods automatically by using [Horizontal Pod Autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler), you should configure cluster autoscaler in AKS too. For details, refer to the official Microsoft documentation at [Cluster autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#cluster-autoscaler).

In addition, if you configure cluster autoscaler, you should create a subnet in a virtual network (VNet) for AKS to ensure a sufficient number of IPs exist so that AKS can work without network issues after scaling. The required number of IPs varies depending on the networking plug-in. For more details about the number of IPs required, refer to the following:

* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Create the AKS cluster on a private network

You should create the AKS cluster on a private network (private subnet in a VNet) since ScalarDL Ledger does not provide any services to users directly via internet access. We recommend accessing ScalarDL Ledger via a private network from your applications.

### Create the AKS cluster by using Azure CNI, if necessary

The AKS default networking plug-in is [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet). If your requirement does not match kubenet, you should use [Azure Container Networking Interface (CNI)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

For example, if you want to deploy multiple ScalarDL Ledger environments on one AKS cluster (e.g., deploy multi-tenant ScalarDL Ledger) and you want to control the connection between each tenant by using [Kubernetes NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/), kubenet supports only the Calico Network Policy, which the [Azure support team does not support](https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-network-policy-manager-and-calico-network-policy-and-their-capabilities). Please note that the Calico Network Policy is supported only by the Calico community or through additional paid support.

The Azure support and engineering teams, however, do support Azure CNI. So, if you want to use Kubernetes NetworkPolicies and receive support from the Azure support team, you should use Azure CNI. For more details about the differences between kubenet and Azure CNI, refer to the following official Microsoft documentation:

* [Network concepts for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/concepts-network)
* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDL Ledger. To restrict unused connections, you can use some security features in Azure, like [network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview).

The connections (ports) that ScalarDL Ledger uses by default are as follows:

* ScalarDL Ledger
    * 50051/TCP (accepts requests from a client)
    * 50052/TCP (accepts privileged requests from a client)
    * 50053/TCP (accepts pause and unpause requests from a scalar-admin client tool)
    * 8080/TCP (accepts monitoring requests)
* Scalar Envoy (used with ScalarDL Ledger)
    * 50051/TCP (load balancing for ScalarDL Ledger)
    * 50052/TCP (load balancing for ScalarDL Ledger)
    * 9001/TCP (accepts monitoring requests for Scalar Envoy itself)

{% capture notice--info %}
**Note**

- If you change the default listening port for ScalarDL Ledger in the configuration file (`ledger.properties`), you must allow connections by using the port that you configured.
- You must also allow the connections that AKS uses itself. For more details about AKS traffic requirements, refer to [Control egress traffic using Azure Firewall in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic).
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>
