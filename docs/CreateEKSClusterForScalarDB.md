# Create an EKS cluster for ScalarDB Server

This document explains how to create an EKS cluster for the ScalarDB Server deployment. For details on how to deploy ScalarDB Server on the EKS cluster, please see [Deploy ScalarDB Server on Amazon EKS (Amazon Elastic Kubernetes Service)](./ManualDeploymentGuideScalarDBServerOnEKS.md).

## Steps

You must create an EKS cluster based on the following requirements, recommendations, and your project's requirements. For details on how to create the EKS cluster, please see the [AWS official document](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html).

## Requirements

There is one requirement for the deployment of ScalarDB Server. Please configure your EKS cluster based on the following requirement and your project's requirements.

* You must create the EKS cluster with Kubernetes version 1.21 or higher for the ScalarDB Server deployment.

## Recommendations (Optional / Not required)

There are some recommendations for the deployment of ScalarDB Server. These are not required. So, you can choose to apply these recommendations or not based on your requirement.

### Use 4vCPU / 8GB memory nodes for the worker node in the ScalarDB Server node group

From the perspective of commercial license, resources for one pod of ScalarDB Server are limited to 2vCPU / 4GB memory. Also, it is recommended to deploy one ScalarDB Server pod and one Envoy pod on one worker node.

In other words, the following components run on the one worker node.

* ScalarDB Server pod (2vCPU / 4GB)
* Envoy proxy (0.2 ~ 0.3 vCPU / 256 ~ 328 MB)
* Kubernetes components

So, you should use the worker node that has 4vCPU / 8GB memory resources. It is recommended to run only the above components on the worker node for ScalarDB Server. However, if you want to run other pods on the worker node for ScalarDB Server, you should use the worker node that has over 4vCPU / 8GB memory.

Note that you should configure resource limits based on your system's workload if the Envoy pod exceeds the above resource usage. Also, you should consider scaling out the worker node and the ScalarDB Server pod if all the ScalarDB Server pod exceeds the above resource usage and the latency is high (throughput is low) in your system.

### Create a node group for other application pods than ScalarDB Server pods

It is recommended to run only pods related to ScalarDB Server on the worker node for ScalarDB Server. If you want to run other application pods on the same EKS cluster, you should create other node groups for your application pods.

### Create a node group for monitoring components (kube-prometheus-stack and loki-stack)

It is recommended to run only pods related to ScalarDB Server on the worker node for ScalarDB Server. If you want to run monitoring pods (Prometheus, Grafana, Loki, etc) by using [kube-prometheus-stack](./K8sMonitorGuide.md) and [loki-stack](./K8sLogCollectionGuide.md) on the same EKS cluster, you should create other node groups for monitoring pods.

### Configure Cluster Autoscaler of EKS

If you want to scale ScalarDB Server pods automatically using [HPA (Horizontal Pod Autoscaler)](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html), you should configure Cluster Autoscaler of EKS too. See the [official document](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler) for more details.

Also, if you configure Cluster Autoscaler, you should create a subnet in VPC for EKS with the prefix (e.g., `/24`) that can ensure a sufficient number of IPs to make EKS work without network issues after scaling.

### Create the EKS cluster on a private network

You should create the EKS cluster on a private network (private subnet in VPC) since ScalarDB Server doesn't provide any services to users directly via internet access. It is better to access ScalarDB Server via a private network from your applications.

### Use three availability zones

To make the EKS cluster has higher availability, you should use several resources in 3 [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as follows.

* Create 3 subnets in different availability zones in the VPC.
* Create at least 3 worker nodes.

### Restrict connections using some security feature based on your requirements

You should restrict unused connections in ScalarDB Server. You can do it using some security features of AWS like [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) and [Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html).

The connections (ports) that ScalarDB Server uses by default are the following. Note that if you change the listening port of ScalarDB Server in a configuration file (`database.properties`) from default, you must allow the connections using the port you configured.

* ScalarDB Server
    * 60051/TCP (Accept the requests from a client)
    * 8080/TCP (Accept the monitoring requests)
* Scalar Envoy (Used with ScalarDB Server)
    * 60051/TCP (Load balancing for ScalarDB Server)
    * 9001/TCP (Accept the monitoring requests of Scalar Envoy itself)

Note that you also must allow the connections that EKS uses itself. Please refer to the [AWS Official Document](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) for more details on Amazon EKS security group requirements.

### Add a **label** to the worker node that is used for **nodeAffinity**

You can make a specific worker node dedicated to ScalarDB Server using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDB Server (e.g., application pods) on the worker node for ScalarDB Server. To add a label to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Server Example
  ```console
  kubectl label node <worker node name> scalar-labs.com/dedicated-node=scalardb
  ```

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set this label when you create a managed node group.

And, if you add this label to make specific worker nodes dedicated to ScalarDB Server, you must configure the following **nodeAffinity** configuration in your custom values file.

* ScalarDB Server Example
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

You can make a specific worker node dedicated to ScalarDB Server using **nodeAffinity** and **taint/toleration** which are the feature of Kubernetes. In other words, you can avoid deploying some pods other than ScalarDB Server (e.g., application pods) on the worker node for ScalarDB Server. To add taint to the worker node, you can use the `kubectl` command as follows.

* ScalarDB Example
  ```console
  kubectl taint node <worker node name> scalar-labs.com/dedicated-node=scalardb:NoSchedule
  ```

Also, if you use [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) of EKS, you can set this taint when you create managed node group. Please refer to the [official document](https://docs.aws.amazon.com/eks/latest/userguide/node-taints-managed-node-groups.html) to configure Kubernetes taints through managed node groups.

And, if you add this taint to make specific worker nodes dedicated to ScalarDB Server, you must configure the following **tolerations** configuration in your custom values file.

* ScalarDB Server Example
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
