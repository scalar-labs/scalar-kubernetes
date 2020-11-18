# How to Manually Create EKS Cluster for Scalar DL deployment.

This document explains how to create an EKS cluster manually for Scalar DL.

## Create AWS Kubernetes cluster

This section explains how to set up an AWS Kubernetes cluster with the AWS console.

### Kubernetes cluster

Please follow [Create a cluster with the AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) with appropriate VPC and Subnets for your system.


### Node Group

Please follow [Create your managed node group using the AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) with the following Scalar DL specific settings.

#### Scalar DL specific settings
Please configure an appropriate **Kubernetes labels**, it will help you to deploy the ledger and envoy in the same node pool. The node pool name specified in the helm configuration file is `agentpool` as key and `scalardlpool` as value,  
So if you are using a different node pool name you should update it in [helm configuration](../conf/scalardl-custom-values.yaml) file also.

Please choose appropriate **Instance type** for Scalar DL, Ledger and envoy will be deployed in the same node so choose the appropriate instance type for that.
              
## Access AKS Cluster
 
Prepare kube config file
```
$ aws eks --region <REGION_NAME> update-kubeconfig --name <EKS_CLUSTER_NAME>
```
