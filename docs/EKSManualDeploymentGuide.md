# How to Manually Deploy Scalar DL on AWS EKS

This document explains how to create an EKS cluster manually and deploy Scalar DL in it.

## Prerequisites

* Terraform >= 0.12.x
* AWS CLI

## How to create

### Configure an AWS credential

```
$ aws configure --profile scalar
```

### Create network resources

Please follow to [Create network resources](https://github.com/scalar-labs/scalar-terraform/blob/master/examples/aws/README.md#create-network-resources).

## Create AWS Kubernetes cluster

This section explains how to set up AWS Kubernetes services with the AWS console.

1. Open the Amazon EKS console at https://console.aws.amazon.com/eks/home#/cluster.
2. Choose Create cluster.
3. On the **Configure cluster** page, fill in the following fields:
    * Enter cluster **Name**.
    * Select **Kubernetes version**.
    * Select **Cluster service role**.  
      Choose the Amazon EKS cluster role to allow the Kubernetes control plane to manage AWS resources on your behalf. For more information, see [Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html) IAM role.
    * Select **Next**.
4. On the **Specify networking** page, select values for the following fields:
    * Select **VPC** created by scalar-terraform.
    * Select **Subnets**. 
        * Select 3 Public Subnets(LoadBalancer) which are created by scalar-terraform.
        * Select 3 ScalarDL Subnet(for nodegroup scalardlpool(envoy and ledger)) which are created by scalar-terraform.
    * Select **Security groups** (Bastion Security group).
    * Choose **Cluster endpoint access** as `Public and private`
    * Select **Next**.
5. On the **Control Plane Logging** page, you can optionally choose which log types that you want to enable.
    * Select **Next**.
6. On the **Review and create** page, review the information that you entered or selected on the previous pages. 
    * Select **Create**.
7. On the newly created EKS cluster page, continue nodegroup creation.
    * Select **Compute** tab.
    * Select **Add Node Group**.
8. On the **Configure Node Group** page, fill in the following fields:
    * Select **Name**.
    * Select **Node IAM Role**. 
    Choose the node instance role to use with your node group. For more information, see [Amazon EKS node](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html) IAM role.
    * Select **Next**.
9. On the **Node Group compute configuration** page, fill out the parameters accordingly:
    * Select **AMI type** as `Amazon Linux 2 (AL2_x86_64)`.
    * Select **Instance type** as `m5.large`.
    * Enter **Disk size** as `64`.
    * Enter **Minimum size** as `3`.
    * Enter **Maximum size** as `3`.
    * Enter **Desired size** as `3`.
    * Select **Next**.
10. On the **Specify networking** page, fill out the parameters accordingly:
    * Select **Subnets**, choose scalardl subnets created by scalar-terraform.
    * Select **SSH key pair**.
    * Select **Next**.
11. On the **Review and create** page, review your managed node group configuration.
    * Select **Create**.                
 
### Create database resources
 
 * Please follow to [Create Cassandra resources](https://github.com/scalar-labs/scalar-terraform/blob/master/examples/aws/README.md#create-cassandra-resources) if you use Cassandra as a backend database.
 * Please follow to [Create Cosmos DB Account](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-cosmosdb.md#cosmos-db-setup) if you use Cosmos DB as a backend database.
 
## Setup Local Machine for Accessing AKS Cluster
 
Prepare kube config file
```
$ aws eks --region <REGION_NAME> update-kubeconfig --name <EKS_CLUSTER_NAME>
```

## How to Deploy Scalar DL

### Configure Docker Registry Access

Create docker registry secrets in kubernetes
```
$ kubectl create secret docker-registry reg-docker-secrets --docker-server=https://index.docker.io/v2/ --docker-username=<DOCKERHUB-USERNAME> --docker-password=<DOCKERHUB--ACCESS-TOKEN>
```

### Deploy Scalar DL

Please follow to [Install Scalar DL](DeployScalarDLHelm.md#install-scalar-dl)
