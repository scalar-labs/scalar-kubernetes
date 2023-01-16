# Create a bastion server

This document explains how to create a bastion server and install some tools for the deployment of Scalar products.

## Create a server on the same private network as a Kubernetes cluster

It is recommended to create a Kubernetes cluster for Scalar products on a private network. If you create a Kubernetes cluster on a private network, you should create a bastion server on the same private network to access your Kubernetes cluster.

## Install tools

Please install the following tools on the bastion server according to their official documents.

* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [helm](https://helm.sh/docs/intro/install/)

## Configure kubeconfig

After you install the kubectl command, you must configure a **kubeconfig** to access your Kubernetes cluster. Please refer to the following official document for more details on how to configure kubeconfig in each managed Kubernetes.

If you use Amazon EKS (Amazon Elastic Kubernetes Service), you must install the **AWS CLI** according to the official document [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). After that, you can see how to configure kubeconfig in [Creating or updating a kubeconfig file for an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html).

If you use AKS (Azure Kubernetes Service), you must install the **Azure CLI** according to the official document [How to install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli). After that, you can see how to configure kubeconfig in [az aks get-credentials](https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-get-credentials).

## Check installation

You can check if the tools are installed as follows.

* kubectl
  ```console
  kubectl version --client
  ```
* helm
  ```console
  helm version
  ```

You can also check if your kubeconfig is properly configured as follows. If you see a URL response, kubectl is correctly configured to access your cluster.
```console
kubectl cluster-info
```
