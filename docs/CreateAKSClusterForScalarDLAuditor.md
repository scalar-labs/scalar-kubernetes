# Guidelines for creating an AKS cluster for ScalarDL Ledger and ScalarDL Auditor

This document explains the requirements and recommendations for creating an Azure Kubernetes Service (AKS) cluster for ScalarDL Ledger and ScalarDL Auditor deployment. For details on how to deploy ScalarDL Ledger and ScalarDL Auditor on an AKS cluster, see [Deploy ScalarDL Ledger and ScalarDL Auditor on AKS](./ManualDeploymentGuideScalarDLAuditorOnAKS.md).

## Before you begin

You must create an AKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an AKS cluster, refer to the following official Microsoft documentation based on the tool you use in your environment:

* [Azure CLI](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-cli)
* [PowerShell](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-powershell)
* [Azure portal](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-portal)

## Requirements

When deploying ScalarDL Ledger and ScalarDL Auditor, you must:

* Create two AKS clusters by using Kubernetes version 1.21 or higher.
    * One AKS cluster for ScalarDL Ledger
    * One AKS cluster for ScalarDL Auditor
* Configure the AKS clusters based on the version of Kubernetes and your project's requirements.
* Configure a virtual network (VNet) as follows.
    * Connect the **VNet of AKS (for Ledger)** and the **VNet of AKS (for Auditor)** by using [virtual network peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-peering). To do so, you must specify the different IP ranges for the **VNet of AKS (for Ledger)** and the **VNet of AKS (for Auditor)** when you create those VNets.
    * Allow **connections between Ledger and Auditor** to make ScalarDL (Auditor mode) work properly.
    * For more details about these network requirements, refer to [Create network peering for ScalarDL Auditor mode // TODO: Add link of new document]().

### Note

For Byzantine fault detection in ScalarDL to work properly, do not deploy your application pods on the same AKS clusters as the ScalarDL Ledger and ScalarDL Auditor deployments.

## Recommendations (optional)

The following are some recommendations for deploying ScalarDL Ledger and ScalarDL Auditor. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger and ScalarDL Auditor node pool

From the perspective of commercial licenses, resources for each pod running ScalarDL Ledger or ScalarDL Auditor is limited to 2vCPU / 4GB memory. In addition, we recommend deploying one ScalarDL Ledger pod and one Envoy pod on each worker node and deploying one ScalarDL Auditor pod and one Envoy pod on each worker node.

In other words, the following components run on one worker node:

* AKS cluster for ScalarDL Ledger
  * ScalarDL Ledger pod (2vCPU / 4GB)
  * Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
  * Kubernetes components
* AKS cluster for ScalarDL Auditor
  * ScalarDL Auditor pod (2vCPU / 4GB)
  * Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
  * Kubernetes components

With this in mind, you should use the worker node that has 4vCPU / 8GB memory resources. We recommend running only the above components on the worker node for ScalarDL Ledger and ScalarDL Auditor. And remember, for Byzantine fault detection to work properly, you cannot deploy your application pods on the same AKS clusters as the ScalarDL Ledger and ScalarDL Auditor deployments.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. In addition, you should consider scaling out the worker node and the ScalarDL Ledger or ScalarDL Auditor pod if the ScalarDL Ledger or ScalarDL Auditor pod exceeds the above resource usage and if latency is high (throughput is low) in your system.

### Create node pools for ScalarDL Ledger and ScalarDL Auditor pods

AKS creates one system node pool named **agentpool** that is preferred for system pods (used to keep AKS running) by default. We recommend creating additional node pools with **user** mode for ScalarDL Ledger and ScalarDL Auditor pods and deploying ScalarDL Ledger and ScalarDL Auditor pods on those additional node pools.

### Create a node pool for monitoring components (kube-prometheus-stack and loki-stack)

We recommend running only pods related to ScalarDL Ledger and ScalarDL Auditor on the worker node for ScalarDL Ledger and ScalarDL Auditor. If you want to run monitoring pods (e.g., Prometheus, Grafana, Loki, etc.) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same AKS cluster, you should create other node pools for monitoring pods.

### Configure cluster autoscaler in AKS

If you want to scale ScalarDL Ledger and ScalarDL Auditor pods automatically by using [Horizontal Pod Autoscaler)](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler), you should configure cluster autoscaler in AKS too. For details, refer to the official Microsoft documentation at [Cluster autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#cluster-autoscaler).

In addition, if you configure cluster autoscaler, you should create a subnet in a VNet for AKS to ensure a sufficient number of IPs exist so that AKS can work without network issues after scaling. The required number of IPs varies depending on the networking plug-in. For more details about the number of IPs required, refer to the following:

* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Create the AKS cluster on a private network

You should create the AKS cluster on a private network (private subnet in a VNet) since ScalarDL Ledger and ScalarDL Auditor do not provide any services to users directly via internet access. We recommend accessing ScalarDL Ledger and ScalarDL Auditor via a private network from your applications.

### Create the AKS cluster by using Azure CNI, if necessary

The AKS default networking plug-in is [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet). If your requirement does not match kubenet, you should use [Azure Container Networking Interface (CNI)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

For example, if you want to deploy multiple ScalarDL Ledger and ScalarDL Auditor environments on only one AKS cluster instead of two AKS clusters (e.g., deploy multi-tenant ScalarDL) and control the connection between each tenant by using [Kubernetes NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/), kubenet supports only the Calico Network Policy, which the [Azure support team does not support](https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-network-policy-manager-and-calico-network-policy-and-their-capabilities). Please note that the Calico Network Policy is supported only by the Calico community or through additional paid support.

The Azure support and engineering teams, however, do support Azure CNI. So, if you want to use Kubernetes NetworkPolicies and receive support from the Azure support team, you should use Azure CNI. For more details about the differences between kubenet and Azure CNI, refer to the following official Microsoft documentation:

* [Network concepts for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/concepts-network)
* [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)

### Use three availability zones

To ensure that the AKS cluster has high availability, you should use several resources in three [availability zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview). To achieve high availability, we recommend creating at least three worker nodes and selecting three availability zones when you create a node pool.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDL and ScalarDL Auditor. To restrict unused connections, you can use some security features of Azure, like [network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview).

The connections (ports) that ScalarDL Ledger and ScalarDL Auditor use by default are as follows. Note that, if you change the default listening port for ScalarDL Ledger and ScalarDL Auditor in their configuration files (`ledger.properties` and `auditor.properties`, respectively), you must allow connections by using the port that you configured.

* ScalarDL Ledger
    * 50051/TCP (accepts requests from a client and ScalarDL Auditor)
    * 50052/TCP (accepts privileged requests from a client and ScalarDL Auditor)
    * 50053/TCP (accepts pause/unpause requests from a scalar-admin client tool)
    * 8080/TCP (accepts monitoring requests)
* ScalarDL Auditor
    * 40051/TCP (accepts requests from a client)
    * 40052/TCP (accepts privileged requests from a client)
    * 40053/TCP (accepts pause and unpause requests from a scalar-admin client tool)
    * 8080/TCP (accepts monitoring requests)
* Scalar Envoy (used with ScalarDL Ledger and ScalarDL Auditor)
    * 50051/TCP (load balancing for ScalarDL Ledger)
    * 50052/TCP (load balancing for ScalarDL Ledger)
    * 40051/TCP (load balancing for ScalarDL Auditor)
    * 40052/TCP (load balancing for ScalarDL Auditor)
    * 9001/TCP (accepts monitoring requests for Scalar Envoy itself)

Note that you also must allow the connections that AKS uses itself. For more details about AKS traffic requirements, refer to [Control egress traffic using Azure Firewall in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic).

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDL Ledger or ScalarDL Auditor by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDL Ledger and non-ScalarDL Auditor pods (e.g., application pods) on the worker node for ScalarDL Ledger and ScalarDL Auditor. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger example
  ```console
  kubectl label node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardl-ledger
  ```
* ScalarDL Auditor example
  ```console
  kubectl label node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardl-auditor
  ```

In addition, you can set these labels in the Azure portal or use the `--labels` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool. If you add these labels to make specific worker nodes dedicated to ScalarDL Ledger and ScalarDL Auditor, you must configure **nodeAffinity** in your custom values file as follows.

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
* ScalarDL Auditor example
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
                    - scalardl-auditor

  auditor:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: scalar-labs.com/dedicated-node
                  operator: In
                  values:
                    - scalardl-auditor
  ```

### Add **taint** to the worker node that is used for **toleration**

You can make a specific worker node dedicated to ScalarDL Ledger or ScalarDL Auditor by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDL Ledger and non-ScalarDL Auditor pods (e.g., application pods) on the worker node for ScalarDL Ledger and ScalarDL Auditor. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger example
  ```console
  kubectl taint node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardl-ledger:NoSchedule
  ```
* ScalarDL Auditor example
  ```console
  kubectl taint node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardl-auditor:NoSchedule
  ```

In addition, you can set these taints in the Azure portal or use the `--node-taints` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool. If you add these taints to make specific worker nodes dedicated to ScalarDL Ledger and ScalarDL Auditor, you must configure **tolerations** in your custom values file as follows.

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
* ScalarDL Auditor example
  ```yaml
  envoy:
    tolerations:
      - effect: NoSchedule
        key: scalar-labs.com/dedicated-node
        operator: Equal
        value: scalardl-auditor

  auditor:
    tolerations:
      - effect: NoSchedule
        key: scalar-labs.com/dedicated-node
        operator: Equal
        value: scalardl-auditor
  ```
