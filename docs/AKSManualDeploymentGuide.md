# How to Manually Deploy Scalar DL on Azure AKS

This document explains how to create an AKS cluster manually and deploy Scalar DL in it.

## Prerequisites

* Terraform >= 0.12.x
* Azure CLI (Latest)

## How to create

### Configure an Azure credential

```
$ az login
```

### Create network resources

Please follow to [Create network resources](ScalarDLonAzureAKS.md#create-network-resources).

### Create Azure Kubernetes cluster

This section explains how to set up Azure Kubernetes services with the Azure portal.

1. Select **Kubernetes services** from the services on Azure portal.
2. Select **Add**.
3. Choose **Add Kubernetes cluster**.
4. On the **Basics** page, configure the following options:
    * Select **Resource group** created by scalar-terraform.
    * Enter the **Kubernetes cluster name**.
    * Select **Region** same as network resource created.
    * Select **Availability zones**.
    * Select **Kubernetes version** as default.
    * Select **Node size** as `Standard D2s v3`.
    * Set the **Node count** as `3`.
    * Select **Next: Node pools** when complete.
5. On the **Node pools** page, configure the following options:
    * Click on **agentpool (primary)**.
    * Change **Node pool name** to `scalardlpool`.
    * Enter **Max pods per node** as `100`.
    * Select **Update**.
    * Select **Next: Authentication** when complete.
6. On the **Authentication** page,
    * Select **Next: Networking** when complete.
7. On the **Networking** page, configure the following options:
    * Select **Network configuration** as `Azure CNI`.
    * Select **Virtual network** created by scalar-terraform.
    * Click on `Manage subnet configuration`.
    * Select **Subnet**.
    * Enter **Name** as `k8s_node_pod`.
    * Enter **Subnet address range** as `10.42.44.0/22`.
    * Select **Ok**.
    * Click on **Create Kubernetes cluster** at top of the page.
    * Select **Cluster subnet** as `k8s_node_pod`.
    * Select **Review + create** when complete.
    * Select **Create**.
    * Wait some time for **Kubernetes cluster** creation.
    
### Create database resources

Please follow to [Create database resources](ScalarDLonAzureAKS.md#create-database-resources).

## Setup Local Machine for Accessing AKS Cluster

Prepare kube config file
```
$ az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME>
```

## How to Deploy Scalar DL

### Configure Docker Registry Access

Create docker registry secrets in kubernetes
```
$ kubectl create secret docker-registry reg-docker-secrets --docker-server=https://index.docker.io/v2/ --docker-username=<DOCKERHUB-USERNAME> --docker-password=<DOCKERHUB--ACCESS-TOKEN>
```

### Deploy Scalar DL

Please follow to [Install Scalar DL](DeployScalarDLHelm.md#install-scalar-dl)
