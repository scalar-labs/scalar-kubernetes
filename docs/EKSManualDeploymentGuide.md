# How to Manually Create EKS Cluster for Scalar DL deployment.

This document explains how to create an EKS cluster manually for Scalar DL.

Here we assume the scalar-terraform network environment is properly created, If you haven't done it, please create it first by following [this](https://github.com/scalar-labs/scalar-terraform/blob/master/examples/aws/README.md#create-network-resources).

## Create AWS Kubernetes cluster

This section explains how to set up an AWS Kubernetes cluster with the AWS console.

### Kubernetes cluster

Please follow to [Create a cluster with the AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) with Scalar DL K8s Cluster Requirements.

#### Scalar DL K8s Cluster Requirements

Page    |Fields  |Default Value  |Remarks    |
--------|--------|---------------|---------------|
Specify networking  |VPC    |   |Should choose VPC created by scalar-terraform  |
Specify networking  |Subnets  |   |Should select 3 Public Subnets for LoadBalancer and 3 ScalarDL Subnet for nodegroup scalardlpool which are created by scalar-terraform  |
Specify networking  |Security groups    |   |Can select bastion Security group created by scalar-terraform or You can change security group based on you requirements   |
Specify networking  |Cluster endpoint access| Public and private| You can change based on your requirements  |

### Node Group

Please follow to [Create your managed node group using the AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) with Scalar DL Node Group Requirements.

#### Scalar DL Node Group Requirements

Page    |Fields  |Default Value  |Remarks    |
--------|--------|---------------|---------------|
Configure Node Group    |Kubernetes labels  |Key=agentpool, Value=scalardlpool    |The label which helps to assign scalar dl pods to specific nodepool. You can change based on your requirements  |
Node Group compute configuration    |AMI type   |Amazon Linux 2 (AL2_x86_64)   |You can change based on your requirements   |
Node Group compute configuration  |Instance type  |m5.large   |You can choose instance type based on your requirements |
Node Group compute configuration  |Disk size  |64   |You can change based on your requirements |
Node Group compute configuration |Minimum size   |3  |You can change based on your requirements   |
Node Group compute configuration |Maximum size   |3  |You can change based on your requirements   |
Node Group compute configuration |Desired size   |3  |You can change based on your requirements   |
Specify networking  |Subnets    |   |Should select scalardl subnets created by scalar-terraform |
              
## Access AKS Cluster
 
Prepare kube config file
```
$ aws eks --region <REGION_NAME> update-kubeconfig --name <EKS_CLUSTER_NAME>
```
