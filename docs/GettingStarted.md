# Getting Started

This Document refers to the various steps in which Scalar DL can be deployed to your infrastructure

## Create a Kubernetes Cluster

To Deploy Scalar DL on a Kubernetes cluster you can follow any of following steps currently Scalar terraform modules are only available for Azure AKS.   

### Azure AKS

To Deploy Scalar DL on Azure AKS the Kubernetes cluster can be created using Terraform or Manually

* To create AKS cluster using scalar terraform modules you can follow [here](./ScalarDLonAKSTerraform.md)     

* To create cluster manually you can follow [here](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal) to getting started on Azure AKS   

### Deploy Scalar DL on Kubernetes Cluster

After creating a Kubernetes cluster the next step is to deploy Scalar DL on it.   

* [Deploy Scalar DL on Azure AKS](./ScalarDLonAzureAKS.md) 

## Create a Kubernetes cluster manually 

Scalar DL can also be deployed on your own Kubernetes Cluster using following methods

First create a Kubernetes Cluster you can refer [here](https://kubernetes.io/docs/setup/production-environment/turnkey/aws/) 

### Deploy Scalar DL on the cluster

To deploy ScalarDL on created Kubernetes cluster you can use the Helm [charts](../charts) and use following methods 

* Deploy Scalar DL manually with [Helm](./DeployScalarDLHelm.md)   

* Deploy Scalar DL using [Ansible Scripts](./DeployScalarDL.md#how-to-deploy-scalar-dl-on-kubernetes-with-ansible)
