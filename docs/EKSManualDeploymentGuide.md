# How to Manually Create EKS Cluster for Scalar DL deployment.

This document explains how to create an EKS cluster manually for Scalar DL.

## Create AWS Kubernetes cluster

### Kubernetes cluster

Please follow [Create a cluster with the AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) with appropriate VPC and Subnets for your system.


### Node Group

Please follow [Create your managed node group using the AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) with the following Scalar DL specific settings.

#### Scalar DL specific settings
please specify the same Kubernetes label for `ledger` and `evnoy`. It will help you to deploy them in the same node group. The current custom config specifies `scalardlpool` for that, so please specify it if you don't have any preference.
Accordingly, the instance type for `ledger` and `envoy` should be selected appropriately. The recommended node size is 3 if you don't have any preference.
              
## Access AKS Cluster
 
Prepare kube config file
```
$ aws eks --region <REGION_NAME> update-kubeconfig --name <EKS_CLUSTER_NAME>
```
