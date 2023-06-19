# Create an ASK cluster for ScalarDL Ledger and ScalarDL Auditor

This document explains how to create an ASK cluster for the ScalarDL Ledger and ScalarDL Auditor deployment. For details on how to deploy ScalarDL Ledger and ScalarDL Auditor on the ASK cluster, please see [Deploy ScalarDL Ledger and ScalarDL Auditor on AKS (Azure Kubernetes Service)](./ManualDeploymentGuideScalarDLAuditorOnAKS.md).

## Steps

You must create an AKS cluster based on the following requirements, recommendations, and your project's requirements. Please refer to the Azure official document ([Azure CLI](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-cli), [PowerShell](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-powershell), or [Azure portal](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-portal)) for the details about how to create the AKS cluster.

## Requirements

There are some requirements for the deployment of ScalarDL Ledger and ScalarDL Auditor. Please configure your ASK cluster based on the following requirement and your project's requirements.

* You must create the ASK cluster with Kubernetes version 1.21 or higher for the ScalarDL Ledger and ScalarDL Auditor deployment.
* You cannot deploy your application pods on the same ASK cluster as ScalarDL Ledger and ScalarDL Auditor deployment to make Byzantine fault detection work properly.
* You must create two ASK clusters. One is for ScalarDL Ledger and another one is for ScalarDL Auditor.
* You must configure a VNet as follows.
    * You must connect the **VNet of AKS (for Ledger)** and the **VNet of AKS (for Auditor)** using [VNet Peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-peering). So, you must specify the different IP ranges for the **VNet of AKS (for Ledger)** and the **VNet of AKS (for Auditor)** when you create them.
    * You must allow the **connections between Ledger and Auditor** to make ScalarDL (Auditor mode) work properly.
    * Please refer to the [Create network peering for ScalarDL Auditor mode // TODO: Add link of new document]() for more details of these network requirements.

## Recommendations (Optional / Not required)

There are some recommendations for the deployment of ScalarDL Ledger and ScalarDL Auditor. These are not required. So, you can choose to apply these recommendations or not based on your requirement.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger and ScalarDL Auditor node pool

From the perspective of commercial license, resources for one pod of ScalarDL Ledger and ScalarDL Auditor are limited to 2vCPU / 4GB memory. Also, it is recommended to deploy "one ScalarDL Ledger pod and one Envoy pod" on one worker node and deploy "one ScalarDL Auditor pod and one Envoy pod" on one worker node as well.

In other words, the following components run on the one worker node.

* ASK cluster for ScalarDL Ledger
  * ScalarDL Ledger pod (2vCPU / 4GB)
  * Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
  * Kubernetes components
* ASK cluster for ScalarDL Auditor
  * ScalarDL Auditor pod (2vCPU / 4GB)
  * Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
  * Kubernetes components

So, you should use the worker node that has 4vCPU / 8GB memory resources. It is recommended to run only the above components on the worker node for ScalarDL Ledger and ScalarDL Auditor. Also, you cannot deploy your application pods on the same ASK cluster as ScalarDL Ledger and ScalarDL Auditor deployment to make Byzantine fault detection work properly.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. Also, you should consider scaling out the worker node and the ScalarDL (Ledger or Auditor) pod if all the ScalarDL (Ledger or Auditor) pod exceeds the above resource usage and the latency is high (throughput is low) in your system.

### Create node pools for ScalarDL Ledger and ScalarDL Auditor pods

AKS creates one system node pool named **agentpool** that is preferred for system pods (used to keep AKS running) by default. It is recommended to create other node pools with **user** mode for ScalarDL Ledger and ScalarDL Auditor pods and deploy ScalarDL Ledger and ScalarDL Auditor pods on those additional node pools.

### Create a node pool for monitoring components (kube-prometheus-stack and loki-stack)

It is recommended to run only pods related to ScalarDL Ledger and ScalarDL Auditor on the worker node for ScalarDL Ledger and ScalarDL Auditor. If you want to run monitoring pods (Prometheus, Grafana, Loki, etc) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same AKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler of AKS

If you want to scale ScalarDL Ledger and ScalarDL Auditor pods automatically using [HPA (Horizontal Pod Autoscaler)](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler), you should configure Cluster Autoscaler of AKS too. Please refer to the [official document](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#cluster-autoscaler) for more details.

Also, if you configure Cluster Autoscaler, you should create a subnet in VNet for AKS to ensure a sufficient number of IPs to make AKS work without network issues after scaling. The required number of IPs is different depending on the networking plug-in. Please refer to the [kubenet document](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet) and the [Azure CNI document](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni) for more details of the number of IPs.

### Create the AKS cluster on a private network

You should create the AKS cluster on a private network (private subnet in VNet) since ScalarDL Ledger and ScalarDL Auditor don't provide any services to users directly via internet access. It is better to access ScalarDL Ledger and ScalarDL Auditor via a private network from your applications.

### Create the AKS cluster with Azure CNI if you need

The default networking plug-in of AKS is [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet). If your requirement doesn't match kubenet, you should use the [Azure CNI](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

For example, if you want to deploy multiple environments of ScalarDL Ledger and ScalarDL Auditor on one AKS cluster (e.g., deploy multi-tenant ScalarDL) and you want to control connection between each tenant using [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/), kubenet supports Calico only and [Calico is not supported by Azure support team](https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-npm-and-calico-network-policy-and-their-capabilities) (it is supported by Calico community or additional paid support).

However, the Azure CNI is Supported by the Azure support and Engineering team. So, if you want to use NetworkPolicy and get support from the Azure support team, you should use Azure CNI. Please refer to the [official document](https://learn.microsoft.com/en-us/azure/aks/concepts-network) for more details of the difference between [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet) and [Azure CNI](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

### Use three availability zones

To make the AKS cluster has higher availability, you should use several resources in 3 [availability zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview) as follows.

* Create at least 3 worker nodes and select 3 availability zones when you create a node pool.

### Restrict connections using some security feature based on your requirements

You should restrict unused connections in ScalarDL and ScalarDL Auditor. You can do it using some security features of Azure like [Network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview).

The connections (ports) that ScalarDL Ledger and ScalarDL Auditor use by default are the following. Note that if you change the listening port of ScalarDL Ledger and ScalarDL Auditor in a configuration file (`ledger.properties` and `auditor.properties`) from default, you must allow the connections using the port you configured.

* ScalarDL Ledger
    * 50051/TCP (Accept the requests from a client and Auditor)
    * 50052/TCP (Accept the privileged requests from a client and Auditor)
    * 50053/TCP (Accept the pause/unpause requests from a scalar-admin client tool)
    * 8080/TCP (Accept the monitoring requests)
* ScalarDL Auditor
    * 40051/TCP (Accept the requests from a client)
    * 40052/TCP (Accept the privileged requests from a client)
    * 40053/TCP (Accept the pause/unpause requests from a scalar-admin client tool)
    * 8080/TCP (Accept the monitoring requests)
* Scalar Envoy (Used with ScalarDL Ledger and ScalarDL Auditor)
    * 50051/TCP (Load balancing for ScalarDL Ledger)
    * 50052/TCP (Load balancing for ScalarDL Ledger)
    * 40051/TCP (Load balancing for ScalarDL Auditor)
    * 40052/TCP (Load balancing for ScalarDL Auditor)
    * 9001/TCP (Accept the monitoring requests of Scalar Envoy itself)

Note that you also must allow the connections that AKS uses itself. Please refer to the [Azure Official Document](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic) for more details of AKS traffic requirements.

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDL Ledger or ScalarDL Auditor using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDL Ledger and ScalarDL Auditor (e.g., application pods) on the worker node for ScalarDL Ledger and ScalarDL Auditor. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardl-ledger
  ```
* ScalarDL Auditor Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardl-auditor
  ```

Also, you can set these labels in the Azure portal or use the `--labels` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool.

And, if you add these labels to make specific worker nodes dedicated to ScalarDL Ledger and ScalarDL Auditor, you must configure the following **nodeAffinity** configuration in your custom values file.

* ScalarDL Ledger Example
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
* ScalarDL Auditor Example
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

You can make a specific worker node dedicated to ScalarDL Ledger or ScalarDL Auditor using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDL Ledger and ScalarDL Auditor (e.g., application pods) on the worker node for ScalarDL Ledger and ScalarDL Auditor. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardl-ledger:NoSchedule
  ```
* ScalarDL Auditor Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardl-auditor:NoSchedule
  ```

Also, you can set these taints in the Azure portal or use the `--node-taints` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool.

And, if you add these taints to make specific worker nodes dedicated to ScalarDL Ledger and ScalarDL Auditor, you must configure the following **tolerations** configuration in your custom values file.

* ScalarDL Ledger Example
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
* ScalarDL Auditor Example
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