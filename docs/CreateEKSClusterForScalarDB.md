# Guidelines for creating an EKS cluster for ScalarDB Server

This document explains the requirements and recommendations for creating an Amazon Elastic Kubernetes Service (EKS) cluster for ScalarDB Server deployment. For details on how to deploy ScalarDB Server on an EKS cluster, see [Deploy ScalarDB Server on Amazon EKS](./ManualDeploymentGuideScalarDBServerOnEKS.md).

## Before you begin

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an EKS cluster, see the official Amazon documentation at [Creating an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html).

## Requirements

When deploying ScalarDB Server, you must:

* Create the EKS cluster by using Kubernetes version 1.21 or higher.
* Configure the EKS cluster based on the version of Kubernetes and your project's requirements.

## Recommendations (optional)

The following are some recommendations for deploying ScalarDB Server. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDB Server node group

From the perspective of commercial licenses, resources for one pod running ScalarDB Server are limited to 2vCPU / 4GB memory. In addition, we recommend deploying one ScalarDB Server pod and one Envoy pod on one worker node.

In other words, the following components run on one worker node:

* ScalarDB Server pod (2vCPU / 4GB)
* Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
* Kubernetes components

With this in mind, you should use a worker node that has 4vCPU / 8GB memory resources. We recommend running only the above components on the worker node for ScalarDB Server. However, if you want to run other pods on the worker node for ScalarDB Server, you should use a worker node that has more than 4vCPU / 8GB memory.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. In addition, you should consider scaling out the worker node and the ScalarDB Server pod if the ScalarDB Server pod exceeds the above resource usage and if latency is high (throughput is low) in your system.

### Create a node group for other application pods than ScalarDB Server pods

We recommend running only ScalarDB Server pods on the worker node (node group) for ScalarDB Server. If you want to run other application pods on the same EKS cluster, you should create other node groups for your application pods.

### Create a node group for monitoring components (kube-prometheus-stack and loki-stack)

We recommend running only pods related to ScalarDB Server on the worker node for ScalarDB Server. If you want to run monitoring pods (e.g., Prometheus, Grafana, Loki, etc.) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same EKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler in EKS

If you want to scale ScalarDB Server pods automatically by using [Horizontal Pod Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler in EKS too. For details, see the official Amazon documentation at [Autoscaling](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler).

In addition, if you configure Cluster Autoscaler, you should create a subnet in an Amazon Virtual Private Cloud (VPC) for EKS with the prefix (e.g., `/24`) to ensure a sufficient number of IPs exist so that EKS can work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in a VPC) since ScalarDB Server does not provide any services to users directly via internet access. We recommend accessing ScalarDB Server via a private network from your applications.

### Use three availability zones

To ensure that the EKS cluster has high availability, you should use several resources in three [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as follows:

* Create three subnets in different availability zones in the VPC.
* Create at least three worker nodes.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDB Server. To restrict unused connections, you can use some security features in AWS, like [security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [network access control lists](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

The connections (ports) that ScalarDB Server uses by default are as follows. Note that, if you change the default listening port for ScalarDB Server in the configuration file (`database.properties`), you must allow connections by using the port that you configured.

* ScalarDB Server
    * 60051/TCP (accepts requests from a client)
    * 8080/TCP (accepts monitoring requests)
* Scalar Envoy (used with ScalarDB Server)
    * 60051/TCP (load balancing for ScalarDB Server)
    * 9001/TCP (accepts monitoring requests for Scalar Envoy itself)

Note that you also must allow the connections that EKS uses itself. For more details about Amazon EKS security group requirements, refer to [Amazon EKS security group requirements and considerations](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html).

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDB Server by using **nodeAffinity** and **taint/toleration**, which are Kubernetes features. In other words, you can avoid deploying non-ScalarDB Server pods (e.g., application pods) on the worker node for ScalarDB Server. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Server example
  ```console
  kubectl label node <WORKER_NODE_NAME> scalar-labs.com/dedicated-node=scalardb
  ```

In addition, if you use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) in EKS, you can set this label when you create a managed node group. If you add this label to make specific worker nodes dedicated to ScalarDB Server, you must configure **nodeAffinity** in your custom values file as follows.

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

In addition, if you use [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) in EKS, you can set this taint when you create a managed node group. For details on how to configure Kubernetes taints through managed node groups, refer to [Node taints on managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/node-taints-managed-node-groups.html).

If you add this taint to make specific worker nodes dedicated to ScalarDB Server, you must configure **tolerations** in your custom values file as follows.

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
