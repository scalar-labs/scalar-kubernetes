# Guidelines for creating an EKS cluster for ScalarDB Cluster

This document explains the requirements and recommendations for creating an Amazon Elastic Kubernetes Service (EKS) cluster for ScalarDB Cluster deployment. For details on how to deploy ScalarDB Cluster on an EKS cluster, see [Deploy ScalarDB Cluster on Amazon EKS](./ManualDeploymentGuideScalarDBClusterOnEKS.md).

## Before you begin

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an EKS cluster, see the official Amazon documentation at [Creating an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html).

## Requirements

When deploying ScalarDB Cluster, you must:

* Create the EKS cluster by using Kubernetes version 1.21 or higher.
* Configure the EKS cluster based on the version of Kubernetes and your project's requirements.

## Recommendations (optional)

The following are some recommendations for deploying ScalarDB Cluster. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDB Cluster node group

From the perspective of commercial licenses, resources for one pod running ScalarDB Cluster are limited to 2vCPU / 4GB memory. In addition, we recommend deploying one ScalarDB Cluster pod and one Envoy pod on one worker node. Note that the Envoy pod does not exist when you use `direct-kubernetes` mode.

In other words, the following components run on one worker node:

* ScalarDB Cluster pod (2vCPU / 4GB)
* Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
* Kubernetes components

With this in mind, you should use a worker node that has 4vCPU / 8GB memory resources. We recommend running only the above components on the worker node for ScalarDB Cluster. However, if you want to run other pods on the worker node for ScalarDB Cluster, you should use a worker node that has more than 4vCPU / 8GB memory.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage in `indirect` mode. In addition, you should consider scaling out the worker node and the ScalarDB Cluster pod if the ScalarDB Cluster pod exceeds the above resource usage and if latency is high (throughput is low) in your system.

### Create a node group for other application pods than ScalarDB Cluster pods

We recommend running only ScalarDB Cluster pods on the worker node (node group) for ScalarDB Cluster. If you want to run other application pods on the same EKS cluster, you should create other node groups for your application pods.

### Create a node group for monitoring components (kube-prometheus-stack and loki-stack)

We recommend running only pods related to ScalarDB Cluster on the worker node for ScalarDB Cluster. If you want to run monitoring pods (e.g., Prometheus, Grafana, Loki, etc.) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same EKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler in EKS

If you want to scale ScalarDB Cluster pods automatically by using [Horizontal Pod Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler in EKS too. For details, see the official Amazon documentation at [Autoscaling](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler).

In addition, if you configure Cluster Autoscaler, you should create a subnet in an Amazon Virtual Private Cloud (VPC) for EKS with the prefix (e.g., `/24`) to ensure a sufficient number of IPs exist so that EKS can work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in a VPC) since ScalarDB Cluster does not provide any services to users directly via internet access. We recommend accessing ScalarDB Cluster via a private network from your applications.

### Use three availability zones

To ensure that the EKS cluster has high availability, you should use several resources in three [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as follows:

* Create three subnets in different availability zones in the VPC.
* Create at least three worker nodes.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDB Cluster. To restrict unused connections, you can use some security features in AWS, like [security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [network access control lists](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

The connections (ports) that ScalarDB Cluster uses by default are as follows. Note that, if you change the default listening port for ScalarDB Cluster in the configuration file (`scalardb-cluster-node.properties`), you must allow connections by using the port that you configured.

* ScalarDB Cluster
    * 60053/TCP (accepts gRPC or SQL requests from a client)
    * 8080/TCP (accepts GraphQL requests from a client)
    * 9080/TCP (accepts monitoring requests)
* Scalar Envoy (used with ScalarDB Cluster `indirect` mode)
    * 60053/TCP (load balancing for ScalarDB Cluster)
    * 9001/TCP (accepts monitoring requests for Scalar Envoy itself)

Note that you also must allow the connections that EKS uses itself. For more details about Amazon EKS security group requirements, refer to [Amazon EKS security group requirements and considerations](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html).

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDB Cluster by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDB Cluster pods (e.g., application pods) on the worker node for ScalarDB Cluster. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Cluster example
  ```console
  kubectl label node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardb-cluster
  ```

In addition, if you use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) in EKS, you can set this label when you create a managed node group. If you add this label to make specific worker nodes dedicated to ScalarDB Cluster, you must configure **nodeAffinity** in your custom values file as follows.

* ScalarDB Cluster example
  * `direct-kubernetes` mode
    ```yaml
    scalardbCluster:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: scalar-labs.com/dedicated-node
                    operator: In
                    values:
                      - scalardb-cluster
    ```
  * `indirect` mode
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
                      - scalardb-cluster

    scalardbCluster:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: scalar-labs.com/dedicated-node
                    operator: In
                    values:
                      - scalardb-cluster
    ```

### Add **taint** to the worker node that is used for **toleration**

You can make a specific worker node dedicated to ScalarDB Cluster by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDB Cluster pods (e.g., application pods) on the worker node for ScalarDB Cluster. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Cluster example
  ```console
  kubectl taint node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardb-cluster:NoSchedule
  ```

In addition, if you use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) in EKS, you can set this taint when you create a managed node group. For details on how to configure Kubernetes taints through managed node groups, refer to [Node taints on managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/node-taints-managed-node-groups.html).

If you add this taint to make specific worker nodes dedicated to ScalarDB Cluster, you must configure **tolerations** in your custom values file as follows.

* ScalarDB Cluster example
  * `direct-kubernetes` mode
    ```yaml
    scalardbCluster: 
      tolerations:
        - effect: NoSchedule
          key: scalar-labs.com/dedicated-node
          operator: Equal
          value: scalardb-cluster
    ```
  * `indirect` mode
    ```yaml
    envoy:
      tolerations:
        - effect: NoSchedule
          key: scalar-labs.com/dedicated-node
          operator: Equal
          value: scalardb-cluster

    scalardbCluster:
      tolerations:
        - effect: NoSchedule
          key: scalar-labs.com/dedicated-node
          operator: Equal
          value: scalardb-cluster
    ```
