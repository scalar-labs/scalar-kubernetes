> [!CAUTION]
> 
> The contents of the `docs` folder have been moved to the [docs-internal-orchestration](https://github.com/scalar-labs/docs-internal-orchestration) repository. Please update this documentation in that repository instead.
> 
> To view the Scalar Kubernetes documentation, visit the documentation site for the product you are using:
> 
> - [ScalarDB Enterprise Documentation](https://scalardb.scalar-labs.com/docs/latest/scalar-kubernetes/deploy-kubernetes/).
> - [ScalarDL Documentation](https://scalardl.scalar-labs.com/docs/latest/scalar-kubernetes/deploy-kubernetes/).

# Production checklist for ScalarDL Ledger

This checklist provides recommendations when deploying ScalarDL Ledger in a production environment.

## Before you begin

In this checklist, we assume that you are deploying ScalarDL Ledger on a managed Kubernetes cluster, which is recommended.

## Production checklist: ScalarDL Ledger

The following is a checklist of recommendations when setting up ScalarDL Ledger in a production environment.

### ScalarDL availability

To ensure that the Kubernetes cluster has high availability, you should use at least three worker nodes and deploy at least three pods spread across the worker nodes. You can see the [sample configurations](../conf/scalardl-custom-values.yaml) of `podAntiAffinity` for making three pods spread across the worker nodes.

{% capture notice--info %}
**Note**

If you place the worker nodes in different availability zones (AZs), you can withstand an AZ failure.
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>

### Resources

From the perspective of commercial licenses, resources for one pod running ScalarDL Ledger are limited to 2vCPU / 4GB memory. In addition to the ScalarDL Ledger pod, Kubernetes could deploy some of the following components to each worker node:

* ScalarDL Ledger pod (2vCPU / 4GB)
* Envoy proxy
* Monitoring components (if you deploy monitoring components such as `kube-prometheus-stack`)
* Kubernetes components

With this in mind, you should use a worker node that has at least 4vCPU / 8GB memory resources and use at least three worker nodes for availability, as mentioned in [ScalarDL availability](#scalardl-availability).

However, three nodes with at least 4vCPU / 8GB memory resources per node is the minimum environment for production. You should also consider the resources of the Kubernetes cluster (for example, the number of worker nodes, vCPUs per node, memory per node, and ScalarDL Ledger pods), which depend on your system's workload. In addition, if you plan to scale the pods automatically by using some features like [Horizontal Pod Autoscaling (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), you should consider the maximum number of pods on the worker node when deciding the worker node resources.

### Network

You should create the Kubernetes cluster on a private network since ScalarDL Ledger does not provide any services to users directly via internet access. We recommend accessing ScalarDL Ledger via a private network from your applications.

### Monitoring and logging

You should monitor the deployed components and collect their logs. For details, see [Monitoring Scalar products on a Kubernetes cluster](./K8sMonitorGuide.md) and [Collecting logs from Scalar products on a Kubernetes cluster](./K8sLogCollectionGuide.md).

### Backup and restore

You should enable the automatic backup feature and point-in-time recovery (PITR) feature in the backend database. For details, see [Set up a database for ScalarDB/ScalarDL deployment](./SetupDatabase.md).

## Production checklist: Client applications that access ScalarDL Ledger

The following is a checklist of recommendations when setting up a client application that accesses ScalarDL Ledger in a production environment.

### Client application deployment

For Byzantine fault detection in ScalarDL to work properly, do not deploy your application pods on the same Kubernetes clusters as the ScalarDL Ledger deployment. Instead, you must deploy your application in an environment other than the administrative domain (other than the Kubernetes cluster) for the ScalarDL Ledger deployment.

#### Required for production environments

```mermaid
graph LR
  subgraph "Administrative domain 1"
    subgraph "Another environment"
      A-1[User application]
    end
  end
  subgraph "Administrative domain 2"
    subgraph "Kubernetes cluster"
      B-1[ScalarDL Ledger]
    end
  end
  A-1 --> B-1
```

#### Not recommended for production environments (for testing purposes only)

```mermaid
graph LR
  subgraph "Kubernetes cluster"
    direction LR
    A-1[User application] --> A-2[ScalarDL Ledger]
  end
```

### Contract and function

To check if your contract and function follow the guidelines, see the following:

* [A Guide on How to Write a Good Contract for ScalarDL](https://github.com/scalar-labs/scalardl/blob/master/docs/how-to-write-contract.md)
* [A Guide on How to Write Function for ScalarDL](https://github.com/scalar-labs/scalardl/blob/master/docs/how-to-write-function.md)

### Contract versioning

After you register a contract, you cannot overwrite that existing contract. So, you should consider the versioning of contracts. We recommend one of the following two methods.

#### Versioning by using `Class Name`

```console
Contract ID              : FooV1
Binary Name              : com.example.contract.FooV1
Class file (Class Name)  : src/main/java/com/example/contract/FooV1.class
---
Contract ID              : FooV2
Binary Name              : com.example.contract.FooV2
Class file (Class Name)  : src/main/java/com/example/contract/FooV2.class
```

#### Versioning by using `Package Name`

```console
Contract ID             : FooV3
Binary Name             : com.example.contract.v3.Foo
Class file (Class Name) : src/main/java/com/example/contract/v3/Foo.class
---
Contract ID             : FooV4
Binary Name             : com.example.contract.v4.Foo
Class file (Class Name) : src/main/java/com/example/contract/v4/Foo.class
```

### Contract limitations

If the binary name, package name, and class name are different when you register the contract, you cannot execute that contract after registering it.

#### Binary name and class name are different (you cannot execute this contract)

```console
Contract ID              : FooV5
Binary Name              : com.example.contract.FooV5
Class file (Class Name)  : src/main/java/com/example/contract/FooV6.class
```

#### Binary name and package name are different (you cannot execute this contract)

```console
Contract ID              : FooV7
Binary Name              : com.example.contract.v7.Foo
Class file (Class Name)  : src/main/java/com/example/contract/v8/Foo.class
```

### Private key and certificate

When you use PKI for authentication, you must make sure that private keys and certificates that you register to ScalarDL Ledger match the following requirements:

```console
Algorithm       : ECDSA
Hash function   : SHA256
Curve parameter : P-256
```

For details, see [How to get a certificate](https://github.com/scalar-labs/scalardl/blob/master/docs/ca/caclient-getting-started.md).

### Exception handling

You must make sure that your application handles exceptions. For details, see [A Guide on How to Handle Errors in ScalarDL](https://github.com/scalar-labs/scalardl/blob/master/docs/how-to-handle-errors.md).
