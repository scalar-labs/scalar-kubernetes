# Getting Started

This Document refers to how to orchestrate the deployment of Scalar DL on Kubernetes cluster.To deploy Scalar DL on a Kubernetes cluster following steps should be followed

* Create Network,Cassandra and Monitor Resources

* Create Kubernetes Cluster

* Deploy Scalar DL on Kubernetes cluster

## Create a Kubernetes Cluster

To Deploy Scalar DL on a Kubernetes cluster you can follow any of following steps currently Scalar terraform modules are only available for Azure AKS.   

* Use Scalar Terraform modules to create the resources for installing Scalar DL.

* Create Kubernetes cluster manually with command line tools. 

### Use Terraform Modules

### AKS

* [How to deploy Kubernetes Cluster and monitor modules on Azure AKS using scalar terraform modules](./ScalarDLonAKSTerraform.md) 

### Create a Kubernetes cluster manually 

* To getting started with Kubernetes cluster deployment manually you can follow [here](https://kubernetes.io/docs/setup/production-environment/turnkey/aws/)

## Install Scalar DL on the Cluster

To deploy ScalarDL on created Kubernetes cluster you can use the Helm [charts](../charts) and use following methods 

### Use Ansible

* [How to deploy Scalar DL using Ansible Scripts on Azure AKS](./ScalarDLonAzureAKS.md) 

### Use Helm

* [How to deploy Scalar DL with Helm](./DeployScalarDLHelm.md)
