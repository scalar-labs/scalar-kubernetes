# Guidelines for creating an EKS cluster for ScalarDL Ledger and ScalarDL Auditor

This document explains the requirements and recommendations for creating an Amazon Elastic Kubernetes Service (EKS) cluster for ScalarDL Ledger and ScalarDL Auditor deployment. For details on how to deploy ScalarDL Ledger and ScalarDL Auditor on an EKS cluster, see [Deploy ScalarDL Ledger and ScalarDL Auditor on Amazon EKS](./ManualDeploymentGuideScalarDLAuditorOnEKS.md).

## Before you begin

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an EKS cluster, see the official Amazon documentation at [Creating an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html).

## Requirements

When deploying ScalarDL Ledger and ScalarDL Auditor, you must:

* Create two EKS clusters by using Kubernetes version 1.21 or higher.
    * One EKS cluster for ScalarDL Ledger
    * One EKS cluster for ScalarDL Auditor
* Configure the EKS clusters based on the version of Kubernetes and your project's requirements.
* Configure an Amazon Virtual Private Cloud (VPC) as follows.
    * Connect the **VPC of EKS (for Ledger)** and the **VPC of EKS (for Auditor)** by using [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html). To do so, you must specify the different IP ranges for the **VPC of EKS (for Ledger)** and the **VPC of EKS (for Auditor)** when you create those VPCs.
    * Allow **connections between Ledger and Auditor** to make ScalarDL (Auditor mode) work properly.
    * For more details about these network requirements, refer to [Create network peering for ScalarDL Auditor mode // TODO: Add link of new document]().

### Note
For Byzantine fault detection in ScalarDL to work properly, do not deploy your application pods on the same EKS clusters as the ScalarDL Ledger and ScalarDL Auditor deployments.

## Recommendations (optional)

The following are some recommendations for deploying ScalarDL Ledger and ScalarDL Auditor. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger and ScalarDL Auditor node group

From the perspective of commercial licenses, resources for each pod running ScalarDL Ledger or ScalarDL Auditor is limited to 2vCPU / 4GB memory. In addition, we recommend deploying one ScalarDL Ledger pod and one Envoy pod on each worker node and deploying one ScalarDL Auditor pod and one Envoy pod on each worker node.

In other words, the following components run on one worker node:

* Amazon EKS cluster for ScalarDL Ledger
  * ScalarDL Ledger pod (2vCPU / 4GB)
  * Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
  * Kubernetes components
* Amazon EKS cluster for ScalarDL Auditor
  * ScalarDL Auditor pod (2vCPU / 4GB)
  * Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
  * Kubernetes components

With this in mind, you should use the worker node that has 4vCPU / 8GB memory resources. We recommend running only the above components on the worker node for ScalarDL Ledger and ScalarDL Auditor. And remember, for Byzantine fault detection to work properly, you cannot deploy your application pods on the same EKS clusters as the ScalarDL Ledger and ScalarDL Auditor deployments.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. In addition, you should consider scaling out the worker node and the ScalarDL Ledger or ScalarDL Auditor pod if the ScalarDL Ledger or ScalarDL Auditor pod exceeds the above resource usage and if latency is high (throughput is low) in your system.

### Create a node group for monitoring components (kube-prometheus-stack and loki-stack)

We recommend running only pods related to ScalarDL Ledger and ScalarDL Auditor on the worker node for ScalarDL Ledger and ScalarDL Auditor. If you want to run monitoring pods (e.g., Prometheus, Grafana, Loki, etc.) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same EKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler in EKS

If you want to scale ScalarDL Ledger or ScalarDL Auditor pods automatically by using [Horizontal Pod Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler in EKS too. For details, see the official Amazon documentation at [Autoscaling](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler).

In addition, if you configure Cluster Autoscaler, you should create a subnet in a VPC for EKS with the prefix (e.g., `/24`) to ensure a sufficient number of IPs exist so that EKS can work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in a VPC) since ScalarDL Ledger and ScalarDL Auditor do not provide any services to users directly via internet access. We recommend accessing ScalarDL Ledger and ScalarDL Auditor via a private network from your applications.

### Use three availability zones

To ensure that the EKS cluster has high availability, you should use several resources in three [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as follows:

* Create three subnets in different availability zones in the VPC.
* Create at least three worker nodes.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDL Ledger and ScalarDL Auditor. To restrict unused connections, you can use some security features in AWS, like [security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [network access control lists](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

The connections (ports) that ScalarDL Ledger and ScalarDL Auditor use by default are as follows. Note that, if you change the default listening port for ScalarDL Ledger and ScalarDL Auditor in their configuration files (`ledger.properties` and `auditor.properties`, respectively), you must allow the connections by using the port that you configured.

* ScalarDL Ledger
    * 50051/TCP (accepts requests from a client and ScalarDL Auditor)
    * 50052/TCP (accepts privileged requests from a client and ScalarDL Auditor)
    * 50053/TCP (accepts pause and unpause requests from a scalar-admin client tool)
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

Note that you also must allow the connections that EKS uses itself. For more details about Amazon EKS security group requirements, refer to [Amazon EKS security group requirements and considerations](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html).

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

In addition, if you use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) in EKS, you can set this label when you create a managed node group. If you add this label to make specific worker nodes dedicated to ScalarDL Ledger and ScalarDL Auditor, you must configure **nodeAffinity** in your custom values file as follows.

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

In addition, if you use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) in EKS, you can set this taint when you create a managed node group. For details on how to configure Kubernetes taints through managed node groups, refer to [Node taints on managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/node-taints-managed-node-groups.html).

If you add these taints to make specific worker nodes dedicated to ScalarDL Ledger and ScalarDL Auditor, you must configure **tolerations** in your custom values file as follows.

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
