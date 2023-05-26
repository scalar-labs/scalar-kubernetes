# Create an EKS cluster for ScalarDL Ledger and ScalarDL Auditor

This document explains how to create an EKS cluster for the ScalarDL Ledger and ScalarDL Auditor deployment. For details on how to deploy ScalarDL Ledger and ScalarDL Auditor on the EKS cluster, please see [Deploy ScalarDL Ledger and ScalarDL Auditor on Amazon EKS (Amazon Elastic Kubernetes Service)](./ManualDeploymentGuideScalarDLAuditorOnEKS.md).

## Steps

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. For details on how to create the EKS cluster, please see the [AWS official document](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html).

## Requirements

There are some requirements for the deployment of ScalarDL Ledger and ScalarDL Auditor. Please configure your EKS cluster based on the following requirement and your project's requirements.

* You must create the EKS cluster with Kubernetes version 1.21 or higher for the ScalarDL Ledger and ScalarDL Auditor deployment.
* You cannot deploy your application pods on the same EKS cluster as ScalarDL Ledger and ScalarDL Auditor deployment to make Byzantine fault detection work properly.
* You must create two EKS clusters. One is for ScalarDL Ledger another one is for ScalarDL Auditor.
* You must configure a VPC as follows.
    * You must connect the **VPC of EKS (for Ledger)** and the **VPC of EKS (for Auditor)** using [VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html). So, you must specify the different IP ranges for the **VPC of EKS (for Ledger)** and the **VPC of EKS (for Auditor)** when you create them.
    * You must allow the **connections between Ledger and Auditor** to make ScalarDL (Auditor mode) work properly.
    * Please refer to the [Create network peering for ScalarDL Auditor mode // TODO: Add link of new document]() for more details of these network requirements.

## Recommendations (Optional / Not required)

There are some recommendations for the deployment of ScalarDL Ledger and ScalarDL Auditor. These are not required. So, you can choose to apply these recommendations or not based on your requirement.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger and ScalarDL Auditor node group

From the perspective of commercial license, resources for one pod of ScalarDL Ledger and ScalarDL Auditor are limited to 2vCPU / 4GB memory. Also, it is recommended to deploy "one ScalarDL Ledger pod and one Envoy pod" on one worker node and deploy "one ScalarDL Auditor pod and one Envoy pod" on one worker node as well.

In other words, the following components run on the one worker node.

* EKS cluster for ScalarDL Ledger
  * ScalarDL Ledger pod (2vCPU / 4GB)
  * Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
  * Kubernetes components
* EKS cluster for ScalarDL Auditor
  * ScalarDL Auditor pod (2vCPU / 4GB)
  * Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
  * Kubernetes components

So, you should use the worker node that has 4vCPU / 8GB memory resources. It is recommended to run only the above components on the worker node for ScalarDL Ledger and ScalarDL Auditor. Also, you cannot deploy your application pods on the same EKS cluster as ScalarDL Ledger and ScalarDL Auditor deployment to make Byzantine fault detection work properly.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. Also, you should consider scaling out the worker node and the ScalarDL (Ledger or Auditor) pod if all the ScalarDL (Ledger or Auditor) pod exceeds the above resource usage and the latency is high (throughput is low) in your system.

### Create a node group for monitoring components (kube-prometheus-stack)

It is recommended to run only pods related to ScalarDL Ledger and ScalarDL Auditor on the worker node for ScalarDL Ledger and ScalarDL Auditor. If you want to run monitoring pods (Prometheus, Grafana, Loki, etc) by using kube-prometheus-stack on the same EKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler of EKS

If you want to scale ScalarDL Ledger or ScalarDL Auditor pods automatically using [HPA (Horizontal Pod Autoscaler)](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler of EKS too. See the [official document](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler) for more details.

Also, if you configure Cluster Autoscaler, you should create a subnet in VPC for EKS with the prefix (e.g., `/24`) that can ensure a sufficient number of IPs to make EKS work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in VPC) since ScalarDL Ledger and ScalarDL Auditor don't provide any services to users directly via internet access. It is better to access ScalarDL Ledger and ScalarDL Auditor via a private network from your applications.

### Use three availability zones

To make the EKS cluster has higher availability, you should use several resources in 3 [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as follows.

* Create 3 subnets in different availability zones in the VPC.
* Create at least 3 worker nodes.

### Restrict connections using some security feature based on your requirements

You should restrict unused connections in ScalarDL Ledger and ScalarDL Auditor. You can do it using some security features of AWS like [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

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

Note that you also must allow the connections that EKS uses itself. Please refer to the [AWS Official Document](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) for more details on Amazon EKS security group requirements.

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

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set these labels when you create a managed node group.

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

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set these taints when you create managed node group. Please refer to the [official document](https://docs.aws.amazon.com/eks/latest/userguide/node-taints-managed-node-groups.html) to configure Kubernetes taints through managed node groups.

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
