# Create an EKS cluster for ScalarDL Ledger

This document explains how to create an EKS cluster for the ScalarDL Ledger deployment. For details on how to deploy ScalarDL Ledger on the EKS cluster, please see [Deploy ScalarDL Ledger on Amazon EKS (Amazon Elastic Kubernetes Service)](./ManualDeploymentGuideScalarDLOnEKS.md).

## Steps

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. For details on how to create the EKS cluster, please see the [AWS official document](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html).

## Requirements

There are some requirements for the deployment of ScalarDL Ledger. Please configure your EKS cluster based on the following requirement and your project's requirements.

* You must create the EKS cluster with Kubernetes version 1.21 or higher for the ScalarDL Ledger deployment.
* You cannot deploy your application pods on the same EKS cluster as ScalarDL Ledger deployment to make Byzantine fault detection work properly.

## Recommendations (Optional / Not required)

There are some recommendations for the deployment of ScalarDL Ledger. These are not required. So, you can choose to apply these recommendations or not based on your requirement.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDL Ledger node group

From the perspective of commercial license, resources for one pod of ScalarDL Ledger are limited to 2vCPU / 4GB memory. Also, it is recommended to deploy one ScalarDL Ledger pod and one Envoy pod on one worker node.

In other words, the following components run on the one worker node.

* ScalarDL Ledger pod (2vCPU / 4GB)
* Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
* Kubernetes components

So, you should use the worker node that has 4vCPU / 8GB memory resources. It is recommended to run only the above components on the worker node for ScalarDL Ledger. Also, you cannot deploy your application pods on the same EKS cluster as ScalarDL Ledger deployment to make Byzantine fault detection work properly.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. Also, you should consider scaling out the worker node and the ScalarDL Ledger pod if all the ScalarDL Ledger pod exceeds the above resource usage and the latency is high (throughput is low) in your system.

### Create a node group for monitoring components (kube-prometheus-stack)

It is recommended to run only pods related to ScalarDL Ledger on the worker node for ScalarDL Ledger. If you want to run monitoring pods (Prometheus, Grafana, Loki, etc) by using kube-prometheus-stack on the same EKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler of EKS

If you want to scale ScalarDL Ledger pods automatically using [HPA (Horizontal Pod Autoscaler)](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler of EKS too. See the [official document](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler) for more details.

Also, if you configure Cluster Autoscaler, you should create a subnet in VPC for EKS with the prefix (e.g., `/24`) that can ensure a sufficient number of IPs to make EKS work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in VPC) since ScalarDL Ledger doesn't provide any services to users directly via internet access. It is better to access ScalarDL Ledger via a private network from your applications.

### Use three availability zones

To make the EKS cluster has higher availability, you should use several resources in 3 [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as follows.

* Create 3 subnets in different availability zones in the VPC.
* Create at least 3 worker nodes.

### Restrict connections using some security feature based on your requirements

You should restrict unused connections in ScalarDL Ledger. You can do it using some security features of AWS like [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

The connections (ports) that ScalarDL Ledger uses by default are the following. Note that if you change the listening port of ScalarDL Ledger in a configuration file (`ledger.properties`) from default, you must allow the connections using the port you configured.

* ScalarDL Ledger
    * 50051/TCP (Accept the requests from a client)
    * 50052/TCP (Accept the privileged requests from a client)
    * 50053/TCP (Accept the pause/unpause requests from a scalar-admin client tool)
    * 8080/TCP (Accept the monitoring requests)
* Scalar Envoy (Used with ScalarDL Ledger)
    * 50051/TCP (Load balancing for ScalarDL Ledger)
    * 50052/TCP (Load balancing for ScalarDL Ledger)
    * 9001/TCP (Accept the monitoring requests of Scalar Envoy itself)

Note that you also must allow the connections that EKS uses itself. Please refer to the [AWS Official Document](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) for more details on Amazon EKS security group requirements.

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDL Ledger using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDL Ledger (e.g., application pods) on the worker node for ScalarDL Ledger. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardl-ledger
  ```

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set this label when you create a managed node group.

And, if you add this label to make specific worker nodes dedicated to ScalarDL Ledger, you must configure the following **nodeAffinity** configuration in your custom values file.

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

### Add **taint** to the worker node that is used for **toleration**

You can make a specific worker node dedicated to ScalarDL Ledger using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDL Ledger (e.g., application pods) on the worker node for ScalarDL Ledger. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDL Ledger Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardl-ledger:NoSchedule
  ```

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set this taint when you create managed node group. Please refer to the [official document](https://docs.aws.amazon.com/eks/latest/userguide/node-taints-managed-node-groups.html) to configure Kubernetes taints through managed node groups.

And, if you add this taint to make specific worker nodes dedicated to ScalarDL Ledger, you must configure the following **tolerations** configuration in your custom values file.

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
