> [!CAUTION]
> 
> The contents of the `docs` folder have been moved to the [docs-internal-orchestration](https://github.com/scalar-labs/docs-internal-orchestration) repository. Please update this documentation in that repository instead.
> 
> To view the Scalar Kubernetes documentation, visit the documentation site for the product you are using:
> 
> - [ScalarDB Enterprise Documentation](https://scalardb.scalar-labs.com/docs/latest/scalar-kubernetes/deploy-kubernetes/).
> - [ScalarDL Documentation](https://scalardl.scalar-labs.com/docs/latest/scalar-kubernetes/deploy-kubernetes/).

# (Deprecated) Guidelines for creating an EKS cluster for ScalarDB Server

{% capture notice--warning %}
**Attention**

ScalarDB Server is now deprecated. Please use [ScalarDB Cluster](./ManualDeploymentGuideScalarDBClusterOnEKS.md) instead.
{% endcapture %}

<div class="notice--warning">{{ notice--warning | markdownify }}</div>

This document explains the requirements and recommendations for creating an Amazon Elastic Kubernetes Service (EKS) cluster for ScalarDB Server deployment. For details on how to deploy ScalarDB Server on an EKS cluster, see [Deploy ScalarDB Server on Amazon EKS](./ManualDeploymentGuideScalarDBServerOnEKS.md).

## Before you begin

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. For specific details about how to create an EKS cluster, see the official Amazon documentation at [Creating an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html).

## Requirements

When deploying ScalarDB Server, you must:

* Create the EKS cluster by using Kubernetes version 1.21 or higher.
* Configure the EKS cluster based on the version of Kubernetes and your project's requirements.

## Recommendations (optional)

The following are some recommendations for deploying ScalarDB Server. These recommendations are not required, so you can choose whether or not to apply these recommendations based on your needs.

### Create at least three worker nodes and three pods

To ensure that the EKS cluster has high availability, you should use at least three worker nodes and deploy at least three pods spread across the worker nodes. You can see the [sample configurations](../conf/scalardb-custom-values.yaml) of `podAntiAffinity` for making three pods spread across the worker nodes.

{% capture notice--info %}
**Note**

If you place the worker nodes in different [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) (AZs), you can withstand an AZ failure.
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDB Server node group

From the perspective of commercial licenses, resources for one pod running ScalarDB Server are limited to 2vCPU / 4GB memory. In addition to the ScalarDB Server pod, Kubernetes could deploy some of the following components to each worker node:

* ScalarDB Server pod (2vCPU / 4GB)
* Envoy proxy
* Your application pods (if you choose to run your application's pods on the same worker node)
* Monitoring components (if you deploy monitoring components such as `kube-prometheus-stack`)
* Kubernetes components

With this in mind, you should use a worker node that has at least 4vCPU / 8GB memory resources and use at least three worker nodes for availability, as mentioned in [Create at least three worker nodes and three pods](#create-at-least-three-worker-nodes-and-three-pods).

However, three nodes with at least 4vCPU / 8GB memory resources per node is the minimum for production environment. You should also consider the resources of the EKS cluster (for example, the number of worker nodes, vCPUs per node, memory per node, ScalarDB Server pods, and pods for your application), which depend on your system's workload. In addition, if you plan to scale the pods automatically by using some features like [Horizontal Pod Autoscaling (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), you should consider the maximum number of pods on the worker node when deciding the worker node resources.

### Configure Cluster Autoscaler in EKS

If you want to scale ScalarDB Server pods automatically by using [Horizontal Pod Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler in EKS too. For details, see the official Amazon documentation at [Autoscaling](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler).

In addition, if you configure Cluster Autoscaler, you should create a subnet in an Amazon Virtual Private Cloud (VPC) for EKS with the prefix (e.g., `/24`) to ensure a sufficient number of IPs exist so that EKS can work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in a VPC) since ScalarDB Server does not provide any services to users directly via internet access. We recommend accessing ScalarDB Server via a private network from your applications.

### Restrict connections by using some security features based on your requirements

You should restrict unused connections in ScalarDB Server. To restrict unused connections, you can use some security features in AWS, like [security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [network access control lists](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

The connections (ports) that ScalarDB Server uses by default are as follows:

* ScalarDB Server
    * 60051/TCP (accepts requests from a client)
    * 8080/TCP (accepts monitoring requests)
* Scalar Envoy (used with ScalarDB Server)
    * 60051/TCP (load balancing for ScalarDB Server)
    * 9001/TCP (accepts monitoring requests for Scalar Envoy itself)

{% capture notice--info %}
**Note**

- If you change the default listening port for ScalarDB Server in the configuration file (`database.properties`), you must allow connections by using the port that you configured.
- You must also allow the connections that EKS uses itself. For more details about Amazon EKS security group requirements, refer to [Amazon EKS security group requirements and considerations](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html).
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>
