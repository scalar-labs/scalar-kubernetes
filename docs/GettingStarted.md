# Getting Started

This document refers to the ways Scalar DL can be deployed in Kubernetes cluster

## Deploy Scalar DL on Azure AKS

Following steps can guide you to install Scalar DL on Azure AKS  

### Install the Requirements

* [Terraform](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#terraform)
* [Ansible](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#ansible)
* [Azure CLI](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#azure-cli-if-using-azure)
* jmespath `pip install jmespath`

#### [Deploy Scalar DL on Azure AKS](./ScalarDLonAzureAKS.md#how-to-deploy-scalar-dl-on-azure-aks) 

## Create a Kubernetes cluster and Install Scalar DL

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
sudo mv helm /usr/local/bin/
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
#### [Ansible](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/GettingStarted.md#ansible)

#### [Create a Kubernetes cluster using command line tools ](https://kubernetes.io/docs/setup/production-environment/turnkey/aws/)

### Deploy Scalar DL on the cluster

* [Deploy Scalar DL with Helm](./DeployScalarDLHelm.md) 

* [Deploy Scalar DL with Ansible](./DeployScalarDL.md#how-to-deploy-scalar-dl-on-kubernetes-with-ansible)


