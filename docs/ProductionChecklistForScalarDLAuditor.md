# Production checklist for ScalarDL Auditor

This checklist provides recommendations when deploying ScalarDL Auditor in a production environment.

## Before you begin

In this checklist, we assume that you are deploying ScalarDL Auditor on a managed Kubernetes cluster, which is recommended.

## Production checklist: ScalarDL Auditor

The following is a checklist of recommendations when setting up ScalarDL Auditor in a production environment.

### Number of pods and Kubernetes worker nodes

To ensure that the Kubernetes cluster has high availability, you should use at least three worker nodes and deploy at least three pods spread across the worker nodes. You can see the [sample configurations](../conf/scalardl-audit-custom-values.yaml) of `podAntiAffinity` for making three pods spread across the worker nodes.

{% capture notice--info %}
**Note**

If you place the worker nodes in different availability zones (AZs), you can withstand an AZ failure.
{% endcapture %}

<div class="notice--info">{{ notice--info | markdownify }}</div>

### Worker node specifications

From the perspective of commercial licenses, resources for one pod running ScalarDL Auditor are limited to 2vCPU / 4GB memory. In addition, some pods other than ScalarDL Auditor pods exist on the worker nodes.

In other words, the following components could run on one worker node:

* ScalarDL Auditor pod (2vCPU / 4GB)
* Envoy proxy
* Monitoring components (if you deploy monitoring components such `kube-prometheus-stack`)
* Kubernetes components

With this in mind, you should use a worker node that has at least 4vCPU / 8GB memory resources and use at least three worker nodes for availability, as mentioned in [Number of pods and Kubernetes worker nodes](#number-of-pods-and-kubernetes-worker-nodes).

However, three nodes with at least 4vCPU / 8GB memory resources per node is the minimum for a production environment. You should also consider the resources of the Kubernetes cluster (for example, the number of worker nodes, vCPUs per node, memories per node, and ScalarDL Auditor pods), which depend on your system's workload. In addition, if you plan to scale the pods automatically by using some features like [Horizontal Pod Autoscaling (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), you should consider the maximum number of pods on the worker node to decide on the worker node resources.

### Network

You should create the Kubernetes cluster on a private network since ScalarDL Auditor does not provide any services to users directly via internet access. We recommend accessing ScalarDL Auditor via a private network from your applications.

### Monitoring and logging

You should monitor the deployed components and collect their logs. For details, see [Monitoring Scalar products on a Kubernetes cluster](./K8sMonitorGuide.md) and [Collecting logs from Scalar products on a Kubernetes cluster](./K8sLogCollectionGuide.md).

### Backup and restore

You should enable the automatic backup feature and point-in-time recovery (PITR) feature in the backend database. For details, see [Set up a database for ScalarDB/ScalarDL deployment](./SetupDatabase.md).

### Do not deploy ScalarDL Auditor on the same Kubernetes cluster as ScalarDL Ledger

For Byzantine fault detection in ScalarDL to work properly, do not deploy ScalarDL Auditor pods on the same Kubernetes clusters as the ScalarDL Ledger deployment. Please deploy ScalarDL Auditor pods on an environment other than the administrative domain (other than the Kubernetes cluster) for ScalarDL Ledger deployment.


#### Required for production environments

```mermaid
graph LR
  subgraph "ScalarDL"
    subgraph "Administrative domain 1"
      subgraph "Kubernetes cluster for Ledger"
        B-1[ScalarDL Ledger]
      end
    end
    subgraph "Administrative domain 2"
      subgraph "Kubernetes cluster for Auditor"
        C-1[ScalarDL Auditor]
      end
    end
  end
```

#### Not recommended for production environments (for testing purposes only)

```mermaid
graph LR
  subgraph "Kubernetes cluster"
    direction LR
    A-1[ScalarDL Ledger]
    A-2[ScalarDL Auditor]
  end
```


### Connect ScalarDL Ledger and ScalarDL Auditor

For ScalarDL Auditor mode to work properly, you must allow the connection between ScalarDL Ledger and ScalarDL Auditor.

```mermaid
graph LR
  subgraph "Kubernetes cluster for Ledger"
    A-1[ScalarDL Ledger]
  end
  subgraph "Kubernetes cluster for Auditor"
    B-1[ScalarDL Auditor]
  end
  A-1 --- B-1
```

ScalarDL uses the following ports for the connections between ScalarDL Ledger and ScalarDL Auditor. You must allow these connections between ScalarDL Ledger and ScalarDL Auditor. 

* ScalarDL Ledger
  * 50051/TCP
  * 50052/TCP
* ScalarDL Auditor
  * 40051/TCP
  * 40052/TCP

### Private key and certificate requirements

When you use PKI for authentication, you must make sure that private keys and certificates that you register to ScalarDL Ledger and ScalaDL Auditor match the following requirements.

```console
Algorithm       : ECDSA
Hash function   : SHA256
Curve parameter : P-256
```

For details, see [How to get a certificate](https://github.com/scalar-labs/scalardl/blob/master/docs/ca/caclient-getting-started.md).

## Production checklist: Client applications that access ScalarDL Auditor

The following is a checklist of recommendations when setting up a client application that accesses ScalarDL Auditor in a production environment.

### Do not deploy your application on the same Kubernetes cluster as ScalarDL

For Byzantine fault detection in ScalarDL to work properly, do not deploy your application pods on the same Kubernetes clusters as the ScalarDL deployment. Please deploy your application on an environment other than the administrative domain (other than the Kubernetes cluster) for ScalarDL deployment.

#### Required for production environments

```mermaid
graph LR
  subgraph "Administrative domain 1"
    subgraph "Another environment"
      A-1[User application]
    end
  end
  subgraph "ScalarDL"
    subgraph "Administrative domain 2"
      subgraph "Kubernetes cluster for Ledger"
        B-1[ScalarDL Ledger]
      end
    end
    subgraph "Administrative domain 3"
      subgraph "Kubernetes cluster for Auditor"
        C-1[ScalarDL Auditor]
      end
    end
  end
  A-1 --> B-1
  A-1 --> C-1
```

#### Not recommended for production environments (for testing purposes only)

```mermaid
graph LR
  subgraph "Kubernetes cluster"
    direction LR
    A-1[User application]
    A-2[ScalarDL Ledger]
    A-3[ScalarDL Auditor]
  end
  A-1 --> A-2
  A-1 --> A-3
```

### Checklist for the client applications that access ScalarDL Ledger

You also must make sure that you satisfy the [Production checklist: Client applications that access ScalarDL Ledger](./ProductionChecklistForScalarDLLedger.md#production-checklist-client-applications-that-access-scalardl-ledger).
