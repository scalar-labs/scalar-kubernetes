# Create an AKS cluster for ScalarDB Server

This document explains how to create an AKS cluster for the ScalarDB Server deployment. For details on how to deploy ScalarDB Server on the AKS cluster, please see [Deploy ScalarDB Server on AKS (Azure Kubernetes Service)](./ManualDeploymentGuideScalarDBServerOnAKS.md).

## Steps

You must create an AKS cluster based on the following requirements, recommendations, and your project's requirements. Please refer to the Azure official document ([Azure CLI](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-cli), [PowerShell](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-powershell), or [Azure portal](https://learn.microsoft.com/ja-jp/azure/aks/learn/quick-kubernetes-deploy-portal)) for the details about how to create the AKS cluster.

## Requirements

There is one requirement for the deployment of ScalarDB Server. Please configure your AKS cluster based on the following requirement and your project's requirements.

* You must create the AKS cluster with Kubernetes version 1.21 or higher for the ScalarDB Server deployment.

## Recommendations (Optional / Not required)

There are some recommendations for the deployment of ScalarDB Server. These are not required. So, you can choose to apply these recommendations or not based on your requirement.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDB Server node pool

From the perspective of commercial license, resources for one pod of ScalarDB Server are limited to 2vCPU / 4GB memory. Also, it is recommended to deploy one ScalarDB Server pod and one Envoy pod on one worker node.

In other words, the following components run on the one worker node.

* ScalarDB Server pod (2vCPU / 4GB)
* Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
* Kubernetes components

So, you should use the worker node that has 4vCPU / 8GB memory resources. It is recommended to run only the above components on the worker node for ScalarDB Server. However, if you want to run other pods on the worker node for ScalarDB Server, you should use the worker node that has over 4vCPU / 8GB memory.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. Also, you should consider scaling out the worker node and the ScalarDB Server pod if all the ScalarDB Server pod exceeds the above resource usage and the latency is high (throughput is low) in your system.

### Create a node pool for ScalarDB Server pods

AKS creates one system node pool named **agentpool** that is preferred for system pods (used to keep AKS running) by default. It is recommended to create another node pool with **user** mode for ScalarDB Server pods and deploy ScalarDB Server pods on this additional node pool.

### Create a node pool for other application pods than ScalarDB Server pods

It is recommended to run only ScalarDB Server pods on the worker node (node pool) for ScalarDB Server. If you want to run other application pods on the same AKS, you should create other node pools for your application pods.

### Create a node group for monitoring components (kube-prometheus-stack)

It is recommended to run only ScalarDB Server pods on the worker node (node pool) for ScalarDB Server. If you want to run monitoring pods (Prometheus, Grafana, Loki, etc) by using kube-prometheus-stack on the same AKS cluster, you should create other node pool for monitoring pods.

### Configure Cluster Autoscaler of AKS

If you want to scale ScalarDB Server pods automatically using [HPA (Horizontal Pod Autoscaler)](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler), you should configure Cluster Autoscaler of AKS too. Please refer to the [official document](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#cluster-autoscaler) for more details.

Also, if you configure Cluster Autoscaler, you should create a subnet in VNet for AKS to ensure a sufficient number of IPs to make AKS work without network issues after scaling. The required number of IPs is different depending on the networking plug-in. Please refer to the [kubenet document](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet) and the [Azure CNI document](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni) for more details of the number of IPs.

### Create the AKS cluster on a private network

You should create the AKS cluster on a private network (private subnet in VNet) since ScalarDB Server doesn't provide any services to users directly via internet access. It is better to access ScalarDB Server via a private network from your applications.

### Create the AKS cluster with Azure CNI if you need

The default networking plug-in of AKS is [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet). If your requirement doesn't match kubenet, you should use the [Azure CNI](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

For example, if you want to deploy multiple environments of ScalarDB Server on one AKS cluster (e.g., deploy multi-tenant ScalarDB Server) and you want to control connection between each tenant using [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/), kubenet supports Calico only and [Calico is not supported by Azure support team](https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-npm-and-calico-network-policy-and-their-capabilities) (it is supported by Calico community or additional paid support).

However, the Azure CNI is Supported by the Azure support and Engineering team. So, if you want to use NetworkPolicy and get support from the Azure support team, you should use Azure CNI. Please refer to the [official document](https://learn.microsoft.com/en-us/azure/aks/concepts-network) for more details of the difference between [kubenet](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet) and [Azure CNI](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni).

### Use three availability zones

To make the AKS cluster has higher availability, you should use several resources in 3 [availability zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview) as follows.

* Create at least 3 worker nodes and select 3 availability zones when you create a node pool.

### Restrict connections using some security feature based on your requirements

You should restrict unused connections in ScalarDB Server. You can do it using some security features of Azure like [Network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview).

The connections (ports) that ScalarDB Server uses by default are the following. Note that if you change the listening port of ScalarDB Server in a configuration file (`database.properties`) from default, you must allow the connections using the port you configured.

* ScalarDB Server
    * 60051/TCP (Accept the requests from a client)
    * 8080/TCP (Accept the monitoring requests)
* Scalar Envoy (Used with ScalarDB Server)
    * 60051/TCP (Load balancing for ScalarDB Server)
    * 9001/TCP (Accept the monitoring requests of Scalar Envoy itself)

Note that you also must allow the connections that AKS uses itself. Please refer to the [Azure Official Document](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic) for more details of AKS traffic requirements.

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDB Server using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDB Server (e.g., application pods) on the worker node for ScalarDB Server. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Server Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardb
  ```

Also, you can set this label in the Azure portal or use the `--labels` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool.

And, if you add this label to make specific worker nodes dedicated to ScalarDB Server, you must configure the following **nodeAffinity** configuration in your custom values file.

* ScalarDB Server Example
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

You can make a specific worker node dedicated to ScalarDB Server using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDB Server (e.g., application pods) on the worker node for ScalarDB Server. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardb:NoSchedule
  ```

Also, you can set this taint in the Azure portal or use the `--node-taints` flag of the [az aks nodepool add](https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-add) command when you create a node pool.

And, if you add this taint to make specific worker nodes dedicated to ScalarDB Server, you must configure the following **tolerations** configuration in your custom values file.

* ScalarDB Server Example
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
