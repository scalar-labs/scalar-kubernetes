# Guidelines for creating an AKS cluster for ScalarDB Server

This document explains the requirements and recommendations for creating an Azure Kubernetes Service (AKS) cluster for ScalarDB Server deployment. For details on how to deploy ScalarDB Server on an AKS cluster, see [Deploy ScalarDB Server on AKS](./ManualDeploymentGuideScalarDBServerOnAKS.md).

## Before you begin

You must create an AKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an AKS cluster, refer to the following official Microsoft documentation based on the tool you use in your environment:

* [Azure CLI](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli)
* [PowerShell](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-powershell)
* [Azure portal](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal)

## Requirements

When deploying ScalarDB Server, you must:

* Create the AKS cluster by using Kubernetes version 1.21 or higher.
* Configure the AKS cluster based on the version of Kubernetes and your project's requirements.

## Recommendations (optional)

The following are some recommendations for deploying ScalarDB Server. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDB Server node pool

From the perspective of commercial licenses, resources for one pod running ScalarDB Server are limited to 2vCPU / 4GB memory. In addition, we recommend deploying one ScalarDB Server pod and one Envoy pod on one worker node.

In other words, the following components run on one worker node:

* ScalarDB Server pod (2vCPU / 4GB)
* Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
* Kubernetes components

With this in mind, you should use a worker node that has 4vCPU / 8GB memory resources. We recommend running only the above components on the worker node for ScalarDB Server. However, if you want to run other pods on the worker node for ScalarDB Server, you should use a worker node that has more than 4vCPU / 8GB memory.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. In addition, you should consider scaling out the worker node and the ScalarDB Server pod if the ScalarDB Server pod exceeds the above resource usage and if latency is high (throughput is low) in your system.

### Create a node pool for ScalarDB Server pods

AKS creates one system node pool named **agentpool** that is preferred for system pods (used to keep AKS running) by default. We recommend creating another node pool with **user** mode for ScalarDB Server pods and deploying ScalarDB Server pods on this additional node pool.

### Create a node pool for other, non-ScalarDB Server application pods

We recommend running only ScalarDB Server pods on the worker node (node pool) for ScalarDB Server. If you want to run other application pods on the same AKS cluster, you should create other node pools for your application pods.

### Create a node pool for monitoring components (kube-prometheus-stack and loki-stack)

We recommend running only ScalarDB Server pods on the worker node (node pool) for ScalarDB Server. If you want to run monitoring pods (e.g., Prometheus, Grafana, Loki, etc.) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same AKS cluster, you should create other node pools for monitoring pods.

### Configure cluster autoscaler in AKS

If you want to scale ScalarDB Server pods automatically by using [Horizontal Pod Autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler), you should configure cluster autoscaler in AKS too. For details, refer to the official Microsoft documentation at [Cluster autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#cluster-autoscaler).

In addition, if you configure cluster autoscaler, you should create a subnet in a virtual network (VNet) for AKS to ensure a sufficient number of IPs exist so that AKS can work without network issues after scaling. The required number of IPs varies depending on the networking plug-in. For more details about the number of IPs required, refer to the following:

* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Create the AKS cluster on a private network

You should create the AKS cluster on a private network (private subnet in a VNet) since ScalarDB Server does not provide any services to users directly via internet access. We recommend accessing ScalarDB Server via a private network from your applications.

### Create the AKS cluster by using Azure CNI, if necessary

The AKS default networking plug-in is [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet). If your requirement does not match kubenet, you should use [Azure Container Networking Interface (CNI)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

For example, if you want to deploy multiple ScalarDB Server environments on one AKS cluster (e.g., deploy a multi-tenant ScalarDB Server) and you want to control the connection between each tenant by using [Kubernetes NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/), kubenet supports only the Calico Network Policy, which the [Azure support team does not support](https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-network-policy-manager-and-calico-network-policy-and-their-capabilities). Please note that the Calico Network Policy is supported only by the Calico community or through additional paid support.

The Azure support and engineering teams, however, do support Azure CNI. So, if you want to use Kubernetes NetworkPolicies and receive support from the Azure support team, you should use Azure CNI. For more details about the differences between kubenet and Azure CNI, refer to the following official Microsoft documentation:

* [Network concepts for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/concepts-network)
* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Use three availability zones

To ensure that the AKS cluster has high availability, you should use several resources in three [availability zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview). To achieve high availability, we recommend creating at least three worker nodes and selecting three availability zones when you create a node pool.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDB Server. To restrict unused connections, you can use some security features in Azure, like [network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview).

The connections (ports) that ScalarDB Server uses by default are as follows. Note that, if you change the default listening port for ScalarDB Server in the configuration file (`database.properties`), you must allow connections by using the port that you configured.

* ScalarDB Server
    * 60051/TCP (accepts requests from a client)
    * 8080/TCP (accepts monitoring requests)
* Scalar Envoy (used with ScalarDB Server)
    * 60051/TCP (load balancing for ScalarDB Server)
    * 9001/TCP (accepts monitoring requests for Scalar Envoy itself)

Note that you also must allow the connections that AKS uses itself. For more details about AKS traffic requirements, refer to [Control egress traffic using Azure Firewall in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic).

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDB Server by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDB Server pods (e.g., application pods) on the worker node for ScalarDB Server. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Server example
  ```console
  kubectl label node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardb
  ```

In addition, you can set this label in the Azure portal or use the `--labels` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool. If you add this label to make specific worker nodes dedicated to ScalarDB Server, you must configure **nodeAffinity** in your custom values file as follows.

* ScalarDB Server example
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
                    - scalardb

  scalardb:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: scalar-labs.com/dedicated-node
                  operator: In
                  values:
                    - scalardb
  ```

### Add **taint** to the worker node that is used for **toleration**

You can make a specific worker node dedicated to ScalarDB Server by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDB Server pods (e.g., application pods) on the worker node for ScalarDB Server. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Server example
  ```console
  kubectl taint node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardb:NoSchedule
  ```

In addition, you can set this taint in the Azure portal or use the `--node-taints` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool. If you add this taint to make specific worker nodes dedicated to ScalarDB Server, you must configure **tolerations** in your custom values file as follows.

* ScalarDB Server example
  ```yaml
  envoy:
    tolerations:
      - effect: NoSchedule
        key: scalar-labs.com/dedicated-node
        operator: Equal
        value: scalardb

  scalardb:
    tolerations:
      - effect: NoSchedule
        key: scalar-labs.com/dedicated-node
        operator: Equal
        value: scalardb
  ```
