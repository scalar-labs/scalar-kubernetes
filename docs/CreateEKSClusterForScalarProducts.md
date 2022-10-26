# Create an EKS cluster for Scalar products

This document explains how to create an EKS cluster for the Scalar DB and Scalar DL deployment. Please refer to the following document for the step overview to deploy each product.

* [Deploy Scalar DB Server on EKS](./ManualDeploymentGuideScalarDBServerOnEKS.md)
* [Deploy Scalar DL Ledger on EKS](./ManualDeploymentGuideScalarDLOnEKS.md)
* [Deploy Scalar DL Ledger and Scalar DL Auditor on EKS](./ManualDeploymentGuideScalarDLAuditorOnEKS.md)

## Steps

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. Please refer to the [AWS official document](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) for the details about how to create the EKS cluster.

## Requirements

There are some requirements for the deployment of Scalar products. Please configure your EKS cluster based on the following requirement and your project's requirements.

### Scalar DB Server

* You must create the EKS cluster with Kubernetes version 1.19 or higher for the Scalar DB deployment.

### Scalar DL Ledger (Ledger only)

* You must create the EKS cluster with Kubernetes version 1.19 or higher for the Scalar DL Ledger deployment.

### Scalar DL Ledger and Auditor (Auditor mode)

* You must create the EKS cluster with Kubernetes version 1.19 or higher for the Scalar DL Ledger and Scalar DL Auditor deployment.
* You must configure a VPC as follows.
    * You must connect the **VPC of EKS (for Ledger)** and the **VPC of EKS (for Auditor)** using [VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html). So, you must specify the different IP ranges for the **VPC of EKS (for Ledger)** and the **VPC of EKS (for Auditor)** when you create them.
    * You must allow the **connections between Ledger and Auditor** to make Scalar DL (Auditor mode) work properly.
    * Please refer to the [Create network peering for Scalar DL Auditor mode // TODO: Add link of new document]() for more details of these network requirements.

## Recommendations (Optional / Not required)

There are some recommendations for the deployment of Scalar products. These are not required. So, you can choose to apply these recommendations or not based on your requirement.

### Use 4vCPU / 8GB memory nodes for the worker node in the Scalar DL node group

From the perspective of commercial license, resources for one pod of Scalar products are limited to 2vCPU / 4GB memory. Also, it is recommended to deploy one Scalar product pod (Scalar DB, Scalar DL Ledger, or Scalar DL Auditor) and one Envoy pod on one worker node.

In other words, the following components run on the one worker node.

* Scalar product pod (2vCPU / 4GB)
* Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
* Kubernetes components

So, you should use the worker node that has 4vCPU / 8GB memory resources. It is recommended to run only the above components on the worker node for Scalar products. However, if you want to run other pods on the worker node for Scalar products, you should use the worker node that has over 4vCPU / 8GB memory.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. Also, you should consider scaling out the worker node and the Scalar product pod if all the Scalar product pod exceeds the above resource usage and the latency is high (throughput is low) in your system.

### Create a node group for other application pods than Scalar product pods

It is recommended to run only pods related to Scalar products on the worker node for Scalar products. If you want to run other application pods on the same EKS, you should create other node groups for your application pods.

### Configure Cluster Autoscaler of EKS

If you want to scale Scalar product pods automatically using [HPA (Horizontal Pod Autoscaler)](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler of EKS too. Please refer to the [official document](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler) for more details.

Also, if you configure Cluster Autoscaler, you should create a subnet in VPC for EKS with the prefix (e.g., `/24`) that can ensure a sufficient number of IPs to make EKS work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in VPC) since Scalar products don't provide any services to users directly via internet access. It is better to access Scalar products via a private network from your applications.

### Use three availability zones

To make the EKS cluster has higher availability, you should use several resources in 3 [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as follows.

* Create 3 subnets in different availability zones in the VPC.
* Create at least 3 worker nodes.

### Restrict connections using some security feature based on your requirements

You should restrict unused connections in Scalar products. You can do it using some security features of AWS like [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

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

Note that you also must allow the connections that are used for EKS itself. Please refer to the [AWS Official Document](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) for more details of Amazon EKS security group requirements.

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

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set these labels when you create a managed node group.

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

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set these taints when you create managed node group. Please refer to the [official document](https://docs.aws.amazon.com/eks/latest/userguide/node-taints-managed-node-groups.html) to configure Kubernetes taints through managed node groups.

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
