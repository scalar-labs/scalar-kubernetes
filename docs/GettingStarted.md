# Getting Started

This document describes how to deploy Scalar DL on Kubernetes Services.

## Requirements

| Name | Version | Mandatory | link |
|:------|:-------|:----------|:------|
| Ansible | 2.9 | yes | https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html |
| Azure CLI | latest | yes | https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest |
| Kubectl | 1.16.13 | yes | https://kubernetes.io/docs/tasks/tools/install-kubectl/ |
| Helm | 3.2.1 or latest | no | https://helm.sh/docs/intro/install/ |

## Directory Notation

### The directory where scalar-kubernetes is cloned

Throughout the documentation, the directory of the cloned copy of scalar-kubernetes on your local machine is referred to as `${SCALAR_K8S_HOME}`. It is a good practice to set the environment variable before you run the commands.

```console
export SCALAR_K8S_HOME=/path/to/scalar-kubernetes
```

### The directory where the configuration files for accessing the Kubernetes cluster are stored

Before running the deployment, please decide which directory you want to use to store configuration files for accessing the Kubernetes cluster.
It is recommended to be set outside of the repo since it should be separately managed per project.
In the documentation, the directory where the configuration files are stored is referred to as `${SCALAR_K8S_CONFIG_DIR}`.

```console
export SCALAR_K8S_CONFIG_DIR=/path/to/scalar-kubernetes-config-dir
```

## Setting up a Kubernetes Service

scalar-kubernetes is a collection of scripts that deploys Scalar DL to a Kubernetes cluster.

scalar-kubernetes has Terraform scripts for creating a set of infrastructure on Azure using modules of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform). It creates Azure Kubernetes Service (AKS) as well as a virtual network, database (Cassandra and Cosmos DB on Azure are supported) resources, and a monitoring/logging service using Prometheus, Grafana, and td-agent. For details, please refer to [How to Create Azure AKS with scalar-terraform](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/AKSScalarTerraformDeploymentGuide.md).

Alternatively, you can use a Kubernetes cluster set up in your own way. For the examples to create Kubernetes services such as AKS on Azure or EKS on AWS manually, please refer to [How to Manually Create AKS Cluster for Scalar DL deployment](./AKSManualDeploymentGuide.md) and [How to Manually Create EKS Cluster for Scalar DL deployment](./EKSManualDeploymentGuide.md).

## Deploying Scalar DL on Kubernetes Service

If you are going to create the infrastructure with Terraform scripts mentioned above, you can use Ansible scripts included in scalar-kubernetes to deploy Scalar DL to AKS. The Ansible scripts apply the Helm charts stored in the [`helm-charts`](https://github.com/scalar-labs/helm-charts/blob/main/charts) repo in an appropriate order automatically. Please follow [How to Deploy Scalar DL on Kubernetes with Ansible](./DeployScalarDLAnsible.md).

You can also apply these Helm charts manually. Please follow [How to Deploy Scalar DL on Kubernetes with Helm Charts](./DeployScalarDLHelm.md) for details.
