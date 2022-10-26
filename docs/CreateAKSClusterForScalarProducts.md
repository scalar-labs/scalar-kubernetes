# Create an AKS cluster for Scalar products

This document explains how to create an AKS cluster for the Scalar DB and Scalar DL deployment. Please refer to the following document for the step overview to deploy each product.

* [Deploy Scalar DB Server on AKS](./ManualDeploymentGuideScalarDBServerOnAKS.md)
* [Deploy Scalar DL Ledger on AKS](./ManualDeploymentGuideScalarDLOnAKS.md)
* [Deploy Scalar DL Ledger and Scalar DL Auditor on AKS](./ManualDeploymentGuideScalarDLAuditorOnAKS.md)

## Steps

You must create an AKS cluster based on the following requirements, recommendations, and your project's requirements. Please refer to the Azure official document ([Azure CLI](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-cli), [PowerShell](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-powershell), or [Azure portal](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-portal)) for the details about how to create the AKS cluster.

## Requirements

There are some requirements for the deployment of Scalar products. Please configure your AKS cluster based on the following requirement and your project's requirements.

### Scalar DB Server

* You must create the AKS cluster with Kubernetes version 1.19 or higher for the Scalar DB deployment.

### Scalar DL Ledger (Ledger only)

* You must create the AKS cluster with Kubernetes version 1.19 or higher for the Scalar DL Ledger deployment.

### Scalar DL Ledger and Auditor (Auditor mode)

* You must create the AKS cluster with Kubernetes version 1.19 or higher for the Scalar DL Ledger and Scalar DL Auditor deployment.
* You must configure a VNet as follows.
    * You must connect the **VNet of AKS (for Ledger)** and the **VNet of AKS (for Auditor)** using [VNet Peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-peering). So, you must specify the different IP ranges for the **VNet of AKS (for Ledger)** and the **VNet of AKS (for Auditor)** when you create them.
    * You must allow the **connections between Ledger and Auditor** to make Scalar DL (Auditor mode) work properly.
    * Please refer to the [Create network peering for Scalar DL Auditor mode // TODO: Add link of new document]() for more details of these network requirements.

## Recommendations (Optional / Not required)

There are some recommendations for the deployment of Scalar products. These are not required. So, you can choose to apply these recommendations or not based on your requirement.

### Use 4vCPU / 8GB memory nodes for the worker node in the Scalar DL node pool

From the perspective of commercial license, resources for one pod of Scalar products are limited to 2vCPU / 4GB memory. Also, it is recommended to deploy one Scalar product pod (Scalar DB, Scalar DL Ledger, or Scalar DL Auditor) and one Envoy pod on one worker node.

In other words, the following components run on the one worker node.

* Scalar product pod (2vCPU / 4GB)
* Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
* Kubernetes components

So, you should use the worker node that has 4vCPU / 8GB memory resources. It is recommended to run only the above components on the worker node for Scalar products. However, if you want to run other pods on the worker node for Scalar products, you should use the worker node that has over 4vCPU / 8GB memory.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. Also, you should consider scaling out the worker node and the Scalar product pod if all the Scalar product pod exceeds the above resource usage and the latency is high (throughput is low) in your system.

### Create a node pool for Scalar product pods

AKS creates one system node pool named **agentpool** that is preferred for system pods (used to keep AKS running) by default. It is recommended to create another node pool with **user** mode for Scalar product pods and deploy Scalar product pods on this additional node pool.

### Create a node pool for other application pods than Scalar product pods

It is recommended to run only Scalar product pods on the worker node (node pool) for Scalar products. If you want to run other application pods on the same AKS, you should create other node pools for your application pods.

### Configure Cluster Autoscaler of AKS

If you want to scale Scalar product pods automatically using [HPA (Horizontal Pod Autoscaler)](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler), you should configure Cluster Autoscaler of AKS too. Please refer to the [official document](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#cluster-autoscaler) for more details.

Also, if you configure Cluster Autoscaler, you should create a subnet in VNet for AKS to ensure a sufficient number of IPs to make AKS work without network issues after scaling. The required number of IPs is different depending on the networking plug-in. Please refer to the [kubenet document](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet) and the [Azure CNI document](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni) for more details of the number of IPs.

### Create the AKS cluster on a private network

You should create the AKS cluster on a private network (private subnet in VNet) since Scalar products don't provide any services to users directly via internet access. It is better to access Scalar products via a private network from your applications.

### Create the AKS cluster with Azure CNI if you need

The default networking plug-in of AKS is [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet). If your requirement doesn't match kubenet, you should use the [Azure CNI](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

For example, if you want to deploy multiple environments of Scalar products on one AKS cluster (e.g., deploy multi-tenant Scalar DL) and you want to control connection between each tenant using [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/), kubenet supports Calico only and [Calico is not supported by Azure support team](https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-npm-and-calico-network-policy-and-their-capabilities) (it is supported by Calico community or additional paid support).

However, the Azure CNI is Supported by the Azure support and Engineering team. So, if you want to use NetworkPolicy and get support from the Azure support team, you should use Azure CNI. Please refer to the [official document](https://learn.microsoft.com/en-us/azure/aks/concepts-network) for more details of the difference between [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet) and [Azure CNI](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

### Use three availability zones

To make the AKS cluster has higher availability, you should use several resources in 3 [availability zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview) as follows.

* Create at least 3 worker nodes and select 3 availability zones when you create a node pool.

### Restrict connections using some security feature based on your requirements

You should restrict unused connections in Scalar products. You can do it using some security features of Azure like [Network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview).

The connections (ports) that are used in Scalar products by default are the following. Note that if you change the listening port of Scalar products in a configuration file (`[database|ledger|auditor].properties`) from default, you must allow the connections using the port you configured.

* Scalar DB Server
    * 60051/TCP (Accept the requests from a client)
    * 8080/TCP (Accept the monitoring requests)
* Scalar DL Ledger
    * 50051/TCP (Accept the requests from a client and Auditor)
    * 50052/TCP (Accept the privileged requests from a client and Auditor)
    * 50053/TCP (Accept the pause/unpause requests from a scalar-admin client tool)
    * 8080/TCP (Accept the monitoring requests)
* Scalar DL Auditor
    * 40051/TCP (Accept the requests from a client)
    * 40052/TCP (Accept the privileged requests from a client)
    * 40053/TCP (Accept the pause/unpause requests from a scalar-admin client tool)
    * 8080/TCP (Accept the monitoring requests)
* Scalar Envoy (Used with Scalar DB Server, Scalar DL Ledger, and Scalar DL Auditor)
    * 9001/TCP (Accept the monitoring requests of Scalar Envoy itself)
    * 60051/TCP (Load balancing for Scalar DB Server)
    * 50051/TCP (Load balancing for Scalar DL Ledger)
    * 50052/TCP (Load balancing for Scalar DL Ledger)
    * 40051/TCP (Load balancing for Scalar DL Auditor)
    * 40052/TCP (Load balancing for Scalar DL Auditor)

Note that you also must allow the connections that are used for AKS itself. Please refer to the [Azure Official Document](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic) for more details of AKS traffic requirements.

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to Scalar products using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than Scalar products (e.g., application pods) on the worker node for Scalar products. To add a label to the worker node, you can use the `kubectl` command as follows.

* Scalar DB Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardb
  ```
* Scalar DL Ledger Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardl-ledger
  ```
* Scalar DL Auditor Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardl-auditor
  ```

Also, you can set these labels in the Azure portal or use the `--labels` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool.

And, if you add these labels to make specific worker nodes dedicated to Scalar products, you must configure the following **nodeAffinity** configuration in your custom values file.

* Scalar DB Example
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
* Scalar DL Ledger Example
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
* Scalar DL Auditor Example
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

You can make a specific worker node dedicated to Scalar products using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than Scalar products (e.g., application pods) on the worker node for Scalar products. To add taint to the worker node, you can use the `kubectl` command as follows.

* Scalar DB Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardb:NoSchedule
  ```
* Scalar DL Ledger Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardl-ledger:NoSchedule
  ```
* Scalar DL Auditor Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardl-auditor:NoSchedule
  ```

Also, you can set these taints in the Azure portal or use the `--node-taints` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool.

And, if you add these taints to make specific worker nodes dedicated to Scalar products, you must configure the following **tolerations** configuration in your custom values file.

* Scalar DB Example
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
* Scalar DL Ledger Example
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
* Scalar DL Auditor Example
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
