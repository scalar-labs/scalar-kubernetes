# Getting Started

This document refers to the possible ways Scalar DL can be deployed in kubernetes cluster, 

## Deploy Scalar DL on Azure AKS

Following steps can guide you to install Scalar DL on Azure AKS  

### Install the Requirements

* [Terraform](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#terraform)
* [Ansible](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#ansible)
* [Azure CLI](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#azure-cli-if-using-azure)
* jmespath `pip install jmespath`

#### [Deploy Scalar DL on Azure AKS](./ScalarDLonAzureAKS.md) 

## Deploy Scalar DL on already created kubernetes cluster

Already have a Kubernetes cluster and need steps to deploy Scalar DL with Helm. You can use the following steps,
 
### Install the Requirements

#### Helm
* Helm install instructions can be found here: https://helm.sh/docs/intro/install/ 
* Please use version 3.2.1 or latest

OSX

```console
brew install helm
```

Linux 

Download desired version of helm from [here](https://github.com/helm/helm/releases)
```console
tar -zxvf helm-v3.2.1-linux-amd64.tar.gz
sudo cp helm /usr/local/bin/
```
#### Kubectl 

* Kubectl install instructions can be found here: https://kubernetes.io/docs/tasks/tools/install-kubectl/ 
* Please use version 1.16.13 

OSX

```console
brew install kubectl 
```
Linux

```console
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.13/bin/linux/amd64/kubectl
chmod +x kubectl  
sudo mv kubectl /usr/local/bin/
```

#### [Deploy Scalar DL with Helm](./DeployScalarDLHelm.md) 

## Deploy Scalar DL on already created kubernetes cluster with Ansible

Already have Kubernetes cluster and need steps to deploy Scalar DL with ansible scripts. You can use the following steps 

### Install the Requirements

* [Ansible](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#ansible)

#### [Deploy Scalar DL with Ansible](./DeployScalarDL.md#how-to-deploy-scalar-dl-on-kubernetes-with-ansible)
