# Create an AKS cluster for ScalarDL Ledger

This document explains how to create an Azure Kubernetes Service (AKS) cluster for ScalarDL Ledger deployment. For details on how to deploy ScalarDL Ledger on an AKS cluster, see [Deploy ScalarDL Ledger on AKS](./ManualDeploymentGuideScalarDLOnAKS.md).

## Before you begin

You must create an AKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an AKS cluster, refer to the following official Microsoft documentation based on the tool you use in your environment:

* [Azure CLI](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli)
* [PowerShell](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-powershell)
* [Azure portal](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal)

## Requirements

When deploying ScalarDL Ledger, you must:

* Create the AKS cluster by using Kubernetes version 1.21 or higher.
* Configure the AKS cluster based on the version of Kubernetes and your project's requirements.

### Note

For Byzantine fault detection in ScalarDL to work properly, do not deploy your application pods on the same AKS cluster as the ScalarDL Ledger deployment.

## Recommendations (Optional / Not required)

The following are some recommendations for deploying ScalarDL Ledger. These recommendations are not required, so you can choose whether or not to apply these recommendations or not based on your needs.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger node pool

From the perspective of commercial licenses, resources for one pod running ScalarDL Ledger are limited to 2vCPU / 4GB memory. In addition, we recommend deploying one ScalarDL Ledger pod and one Envoy pod on one worker node.

In other words, the following components run on one worker node:

* ScalarDL Ledger pod (2vCPU / 4GB)
* Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
* Kubernetes components

With this in mind, you should use a worker node that has 4vCPU / 8GB memory resources. We recommend running only the above components on the worker node for ScalarDL Ledger. And remember, for Byzantine fault detection to work properly, you cannot deploy your application pods on the same AKS cluster as the ScalarDL Ledger deployment.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. In addition, you should consider scaling out the worker node and the ScalarDL Ledger pod if the ScalarDL Ledger pod exceeds the above resource usage and if latency is high (throughput is low) in your system.

### Create a node pool for ScalarDL Ledger pods

AKS creates one system node pool named **agentpool** that is preferred for system pods (used to keep AKS running) by default. We recommend creating another node pool with **user** mode for ScalarDL Ledger pods and deploying ScalarDL Ledger pods on this additional node pool.

### Create a node pool for monitoring components (kube-prometheus-stack and loki-stack)

We recommend running only pods related to ScalarDL Ledger on the worker node for ScalarDL Ledger. If you want to run monitoring pods (e.g., Prometheus, Grafana, Loki, etc.) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same AKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler in AKS

If you want to scale ScalarDL Ledger pods automatically by using [horizontal pod autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler), you should configure cluster autoscaler in AKS too. For details, refer to the official Microsoft documentation at [Cluster autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#cluster-autoscaler).

In addition, if you configure Cluster Autoscaler, you should create a subnet in a virtual network (VNet) for AKS to ensure a sufficient number of IPs exist so that AKS can work without network issues after scaling. The required number of IPs varies depending on the networking plug-in. For more details about the number of IPs required, refer to the following: 

* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Create the AKS cluster on a private network

You should create the AKS cluster on a private network (private subnet in a VNet) since ScalarDL Ledger does not provide any services to users directly via internet access. We recommend accessing ScalarDL Ledger via a private network from your applications.

### Create the AKS cluster by using Azure CNI, if necessary

The AKS default networking plug-in is [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet). If your requirement does not match kubenet, you should use [Azure Container Networking Interface (CNI)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

For example, if you want to deploy multiple ScalarDL Ledger environments on one AKS cluster (e.g., deploy multi-tenant ScalarDL Ledger) and you want to control the connection between each tenant by using [Kubernetes NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/), kubenet supports only Calico, and [the Azure support team does not support Calico](https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-npm-and-calico-network-policy-and-their-capabilities). Please note that Calico is supported only by the Calico community or through additional paid support.

The Azure support and engineering teams, however, do support Azure CNI. So, if you want to use Kubernetes NetworkPolicies and receive support from the Azure support team, you should use Azure CNI. For more details about the differences between kubenet and Azure CNI, refer to the following official Microsoft documentation:

* [Network concepts for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/concepts-network)
* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Use three availability zones

To ensure that the AKS cluster has high availability, you should use several resources in three [availability zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview). To achieve high availability, we recommend creating at least three worker nodes and selecting three availability zones when you create a node pool.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDL Ledger. To restrict unused connections, you can use some security features in Azure, like [network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview).

The connections (ports) that ScalarDL Ledger uses by default are as follows. Note that, if you change the default listening port for ScalarDL Ledger in the configuration file (`ledger.properties`), you must allow connections by using the port that you configured.

* ScalarDL Ledger
    * 50051/TCP (accepts requests from a client)
    * 50052/TCP (accepts privileged requests from a client)
    * 50053/TCP (accepts pause and unpause requests from a scalar-admin client tool)
    * 8080/TCP (accepts monitoring requests)
* Scalar Envoy (used with ScalarDL Ledger)
    * 50051/TCP (load balancing for ScalarDL Ledger)
    * 50052/TCP (load balancing for ScalarDL Ledger)
    * 9001/TCP (accepts monitoring requests for Scalar Envoy itself)

Note that you also must allow the connections that AKS uses itself. For more details about AKS traffic requirements, refer to [Control egress traffic using Azure Firewall in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic).

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDL Ledger by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDL Ledger pods (e.g., application pods) on the worker node for ScalarDL Ledger. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger example
  ```console
  kubectl label node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardl-ledger
  ```

In addition, you can set this label in the Azure portal or use the `--labels` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool. If you add this label to make specific worker nodes dedicated to ScalarDL Ledger, you must configure **nodeAffinity** in your custom values file as follows.

* ScalarDL Ledger example
  ```yaml
  envoy:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: scalar-labs.com/dedicated-node
                  operator: In
                  values:
                    - scalardl-ledger

  ledger:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: scalar-labs.com/dedicated-node
                  operator: In
                  values:
                    - scalardl-ledger
  ```

### Add **taint** to the worker node that is used for **toleration**

You can make a specific worker node dedicated to ScalarDL Ledger by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDL Ledger pods (e.g., application pods) on the worker node for ScalarDL Ledger. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger example
  ```console
  kubectl taint node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardl-ledger:NoSchedule
  ```

In addition, you can set this taint in the Azure portal or use the `--node-taints` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool. If you add this taint to make specific worker nodes dedicated to ScalarDL Ledger, you must configure **tolerations** in your custom values file as follows.

* ScalarDL Ledger example
  ```yaml
  envoy:
    tolerations:
      - effect: NoSchedule
        key: scalar-labs.com/dedicated-node
        operator: Equal
        value: scalardl-ledger

  ledger:
    tolerations:
      - effect: NoSchedule
        key: scalar-labs.com/dedicated-node
        operator: Equal
        value: scalardl-ledger
  ```
