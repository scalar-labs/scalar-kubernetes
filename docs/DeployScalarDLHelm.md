# Deploy Scalar DL with Helm

This document explains how to deploy Scalar Ledger and Envoy on Kubernetes with Helm.

## Assumptions

The document assumes the following.

* You have the authority to pull `scalarlabs/scalar-ledger` and `scalarlabs/scalardl-schema-loader` docker repositories. (they are only available to our partners and customers at the moment)
* The backend database that Scalar DL accesses is started properly
* A Kubernetes cluster has been already created and you have access to it

## Requirements

| Name | Version | Mandatory | link |
|:------|:-------|:----------|:------|
| Kubectl | 1.16.13 | yes | https://kubernetes.io/docs/tasks/tools/install-kubectl/ |
| Helm | 3.2.1 or latest | yes | https://helm.sh/docs/intro/install/ |

## Preparation

### Prepare kubeconfig file

If you [created the Kubernetes cluster with scalar-terraform](./AKSScalarTerraformDeploymentGuide.md), you can get the config file from the output of `terraform output`.

```console
cd ${SCALAR_K8S_HOME}/modules/azure/kubernetes/
terraform output kube_config > ~/.kube/config
```

If you use your own Kubernetes cluster, please prepare the config file by yourself to communicate with the cluster by running commands e.g. `az aks get-credentials` or `aws eks update-kubeconfig`.

### Create docker registry secrets in kubernetes

Create a secret for the Docker registory with the following command.

```console
kubectl create secret docker-registry reg-docker-secrets --docker-server=https://index.docker.io/v2/ --docker-username=<dockerhub-username> --docker-password=<dockerhub-access-token>
```

## Install Scalar DL

```console
# Load Schema for Scalar DL install with a release name `load-schema`
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade --install load-schema charts/stable/schema-loading --namespace default -f conf/schema-loading-custom-values.yaml

# Install Scalar DL with a release name `my-release-scalardl`
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade --install my-release-scalardl charts/stable/scalardl --namespace default -f conf/scalardl-custom-values.yaml
```

Note:

* The same commands can be used to upgrade the pods.
* Release name `my-release-scalardl` can be changed as per your convenience.
* `helm ls -a` command can be used to list currently installed releases.

## Uninstall Scalar DL

```console
# Uninstall loaded schema with a release name 'load-schema'
$ cd ${SCALAR_K8S_HOME}
$ helm delete load-schema

# Uninstall scalar DL with a release name 'my-release-scalardl'   
$ cd ${SCALAR_K8S_HOME}
$ helm delete my-release-scalardl
```

## Configuration

See the [Configurations](../charts/stable/scalardl/README.md#scalardl) used in the Charts
