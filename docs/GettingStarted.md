# Getting Started

This document describes how to deploy Scalar DL on Kubernetes Services.

## Requirements

| Name | Version | Mandatory | link |
|:------|:-------|:----------|:------|
| Ansible | 2.9 | yes | https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html |
| Terraform | 0.12.x | no | https://learn.hashicorp.com/terraform/getting-started/install |
| Docker | latest | no | https://docs.docker.com/install/ |
| Azure CLI | latest | yes | https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest |
| Kubectl | 1.16.13 | yes | https://kubernetes.io/docs/tasks/tools/install-kubectl/ |
| Helm | 3.2.1 or latest | no | https://helm.sh/docs/intro/install/ |
| Minikube | latest | no | https://kubernetes.io/docs/setup/learning-environment/minikube/ |
| jmespath | latest | yes | https://github.com/jmespath/jmespath.py |

## Directory Notations

Throughout the documentation, the directory of the cloned copy of scalar-k8s on your local machine is referred as `${SCALAR_K8S_HOME}`. It is a good idea to set the environment variable before you run the commands.

```console
export SCALAR_K8S_HOME=/path/to/scalar-k8s
```

### Decide where to store configuration files for accessing the k8s cluster

Before running the deployment, please decide which directory you want to use to store configuration files for accessing the Kubernetes cluster.
It is recommended to be set outside of the repo since it should be separately managed per project.
In the documentation, the directory where the configuration files are stored is referred as `${SCALAR_K8S_CONFIG_DIR}`.

```console
export SCALAR_K8S_CONFIG_DIR=/path/to/scalar-k8s-config-dir
```

## Setting up Kubernetes Service

scalar-k8s is a collection of scripts that deploys Scalar DL to a Kubernetes cluster.

scalar-k8s has Terraform scripts for creating a set of infrastructure on Azure using modules of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform). It creates Azure Kubernetes Service (AKS) as well as a virtual network, database (Cassandra and Cosmos DB on Azure are supported) resources and a monitoring/logging service using Prometheus, Grafana, and td-agent. For details, please refer to [How to Create Azure AKS with scalar-terraform](./AKSScalarTerraformDeploymentGuide.md).

Alternatively, you can use your own Kubernetes cluster. For the examples to create Kubernetes services such as AKS on Azure or EKS on AWS manually, please refer to [How to Manually Create AKS Cluster for Scalar DL deployment](./AKSManualDeploymentGuide.md) and [How to Manually Create AKS Cluster for Scalar DL deployment](./AKSManualDeploymentGuide.md).

### Deploying Scalar DL on Kubernetes Service

If you are going to create the infrastructure with Terraform scripts mentioned above, you can use Ansible scripts included in scalar-k8s to deploy Scalar DL to AKS. Please follow [How to Deploy Scalar DL on Kubernetes with Ansible](./DeployScalarDLAnsible.md).

The Ansible scripts use the Helm charts stored in the [`charts`](../charts) directory. You can run these Helm charts directly if you are going to use your own Kubernetes cluster. You can even use this option on an infrastructure created with the Terraform scripts instead of running them from Ansible. Please follow [How to Deploy Scalar DL on Kubernetes with Helm Charts](./DeployScalarDLHelm.md) for details.
