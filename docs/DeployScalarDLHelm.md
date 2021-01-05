# Deploy Scalar DL with Helm

This document explains how to deploy Scalar Ledger and Envoy on Kubernetes with Helm.

## Assumptions

The document assumes the following.

* You have the authority to pull `ghcr.io/scalar-labs/scalar-ledger` and `ghcr.io/scalar-labs/scalardl-schema-loader` docker repositories. (they are only available to our partners and customers at the moment)
* The backend database that Scalar DL accesses is started properly
* A Kubernetes cluster has been already created, and you have access to it

## Requirements

| Name | Version | Mandatory | link |
|:------|:-------|:----------|:------|
| Kubectl | 1.16.13 | yes | https://kubernetes.io/docs/tasks/tools/install-kubectl/ |
| Helm | 3.2.1 or latest | yes | https://helm.sh/docs/intro/install/ |

## Preparation

### Prepare kubeconfig file

Please select one depending on how you created a Kubernetes cluster.

#### Case 1: Use a Kubernetes cluster created with scalar-terraform

This is the case where you created a Kubernetes cluster with [scalar-terraform](https://github.com/scalar-labs/scalar-terraform).
The Kubernetes cluster in the scalar-terraform network doesn't expose the API server to the outside of the network. You will need an SSH port-forwarded access to the Kubernetes API to install the Helm charts. Please follow [How to do port-forwarding to Kubnernetes API in scalar-terraform network](./PortForwardingToK8sAPIInScalarTerraformNetwork.md) to get the configuration.

#### Case 2: Use a Kubernetes cluster created manually or by other ways than scalar-terraform

If you use a Kubernetes cluster created manually or by other ways than scalar-terraform, please prepare the config file by yourself to communicate with the cluster by running commands, for example, `az aks get-credentials` or `aws eks update-kubeconfig`.

### Create docker registry secrets in kubernetes

Create a secret for the Docker registry with the following command.

```console
kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<dockerhub-username> --docker-password=<dockerhub-access-token>
```

## Install Scalar DL

Before installing Scalar DL with the `helm` command, copy the Helm values files from the `conf` directory to `${SCALAR_K8S_CONFIG_DIR}`.

```console
cp ${SCALAR_K8S_HOME}/conf/{scalardl-custom-values.yaml,schema-loading-custom-values.yaml} ${SCALAR_K8S_CONFIG_DIR}/
```

At this point, you need to update these Helm values files to configure the database. Please follow [Configure Database](./HelmValuesFiles.md#configure-database) in the Helm values files documentation.

Now it is ready to run the helm commands to install Scalar DL.

```console
# Load Schema for Scalar DL install with a release name `load-schema`
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade --install load-schema charts/stable/schema-loading --namespace default -f ${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml

# Install Scalar DL with a release name `my-release-scalardl`
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade --install my-release-scalardl charts/stable/scalardl --namespace default -f ${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml
```

Note:

* The same commands can be used to upgrade the pods.
* Release name `my-release-scalardl` can be changed as per your convenience.
* `helm ls -a` command can be used to list currently installed releases.

## Advanced Configuration

To further customize the Helm charts, please refer to [How to customize values for Scalar DL and Schema Loading Helm charts](./HelmValuesFiles.md).

## Uninstall Scalar DL

```console
# Uninstall loaded schema with a release name 'load-schema'
$ cd ${SCALAR_K8S_HOME}
$ helm delete load-schema

# Uninstall scalar DL with a release name 'my-release-scalardl'
$ cd ${SCALAR_K8S_HOME}
$ helm delete my-release-scalardl
```
