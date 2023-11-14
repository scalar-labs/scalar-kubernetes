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
    * For more details about these network requirements, refer to [Configure Network Peering for ScalarDL Auditor Mode](./NetworkPeeringForScalarDLAuditor.md).

{% capture notice--warning %}
**Attention**

For Byzantine fault detection in ScalarDL to work properly, do not deploy your application pods on the same EKS clusters as the ScalarDL Ledger and ScalarDL Auditor deployments.
{% endcapture %}

<div class="notice--warning">{{ notice--warning | markdownify }}</div>

## Recommendations (optional)

The following are some recommendations for deploying ScalarDL Ledger and ScalarDL Auditor. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Create at least three worker nodes and three pods per EKS cluster

To ensure that the EKS cluster has high availability, you should use at least three worker nodes and deploy at least three pods spread across the worker nodes. You can see the [ScalarDL Ledger sample configurations](../conf/scalardl-custom-values.yaml) and [ScalarDL Auditor sample configurations](../conf/scalardl-audit-custom-values.yaml) of `podAntiAffinity` for making three pods spread across the worker nodes.

{% capture notice--info %}
**Note**

If you place the worker nodes in different [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) (AZs), you can withstand an AZ failure.
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger and ScalarDL Auditor node group

From the perspective of commercial licenses, resources for each pod running ScalarDL Ledger or ScalarDL Auditor are limited to 2vCPU / 4GB memory. In addition to the ScalarDL Ledger and ScalarDL Auditor pods, Kubernetes could deploy some of the following components to each worker node:

* EKS cluster for ScalarDL Ledger
  * ScalarDL Ledger pod (2vCPU / 4GB)
  * Envoy proxy
  * Monitoring components (if you deploy monitoring components such as `kube-prometheus-stack`)
  * Kubernetes components
* EKS cluster for ScalarDL Auditor
  * ScalarDL Auditor pod (2vCPU / 4GB)
  * Envoy proxy
  * Monitoring components (if you deploy monitoring components such as `kube-prometheus-stack`)
  * Kubernetes components

With this in mind, you should use a worker node that has at least 4vCPU / 8GB memory resources and use at least three worker nodes for availability, as mentioned in [Create at least three worker nodes and three pods](#create-at-least-three-worker-nodes-and-three-pods-per-eks-cluster). And remember, for Byzantine fault detection to work properly, you cannot deploy your application pods on the same EKS clusters as the ScalarDL Ledger and ScalarDL Auditor deployments.

However, three nodes with at least 4vCPU / 8GB memory resources per node is a minimum environment for production. You should also consider the resources of the EKS cluster (for example, the number of worker nodes, vCPUs per node, memory per node, ScalarDL Ledger pods, and ScalarDL Auditor pods), which depend on your system's workload. In addition, if you plan to scale the pods automatically by using some features like [Horizontal Pod Autoscaling (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), you should consider the maximum number of pods on the worker node when deciding the worker node resources.

### Configure Cluster Autoscaler in EKS

If you want to scale ScalarDL Ledger or ScalarDL Auditor pods automatically by using [Horizontal Pod Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler in EKS too. For details, see the official Amazon documentation at [Autoscaling](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler).

In addition, if you configure Cluster Autoscaler, you should create a subnet in a VPC for EKS with the prefix (e.g., `/24`) to ensure a sufficient number of IPs exist so that EKS can work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in a VPC) since ScalarDL Ledger and ScalarDL Auditor do not provide any services to users directly via internet access. We recommend accessing ScalarDL Ledger and ScalarDL Auditor via a private network from your applications.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDL Ledger and ScalarDL Auditor. To restrict unused connections, you can use some security features in AWS, like [security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [network access control lists](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

The connections (ports) that ScalarDL Ledger and ScalarDL Auditor use by default are as follows:

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

{% capture notice--info %}
**Note**

- If you change the default listening port for ScalarDL Ledger and ScalarDL Auditor in their configuration files (`ledger.properties` and `auditor.properties`, respectively), you must allow the connections by using the port that you configured.
- You must also allow the connections that EKS uses itself. For more details about Amazon EKS security group requirements, refer to [Amazon EKS security group requirements and considerations](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html).
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>
