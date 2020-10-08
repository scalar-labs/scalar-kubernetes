# Deploy Scalar DL with Helm

This document explains how to deploy Scalar Ledger and Envoy on Kubernetes with Helm.

## Requirements

| Name | Version | Mandatory | link |
|:------|:-------|:----------|:------|
| Kubectl | 1.16.13 | yes | https://kubernetes.io/docs/tasks/tools/install-kubectl/ |
| Helm | 3.2.1 or latest | yes | https://helm.sh/docs/intro/install/ |

* An authority to pull `scalarlabs/scalar-ledger` and `scalarlabs/scalardl-schema-loader-cassandra` docker repositories.
  * `scalar-ledger` and `scalardl-schema-loader-cassandra` are available to only our partners and customers at the moment.

Note that this document assumes a Kubernetes cluster has been already created and you have access to it.

## Preparation
Prepare environment variables for easy access and add docker registry secrets in kubernetes.

```console
# Please update `/path/to/local-repository` before running the command.
$ export SCALAR_K8S_HOME=/path/to/local-repository

# Prepare kubeconfig file
$ cd ${SCALAR_K8S_HOME}/examples/azure/kubernetes/
$ terraform output kube_config > ~/.kube/config

# Create docker registry secrets in kubernetes
$ kubectl create secret docker-registry reg-docker-secrets --docker-server=https://index.docker.io/v2/ --docker-username=<dockerhub-username> --docker-password=<dockerhub-access-token>
```
## Install Scalar DL

```console
# Load Schema for scalar dl install with release name load-schema
$ cd ${SCALAR_K8S_HOME}
$ helm install load-schema --namespace default -f conf/schema-loading-custom-values.yaml charts/stable/schema-loading

# Install scalar dl with release name prod
$ cd ${SCALAR_K8S_HOME}
$ helm install prod --namespace default -f conf/scalardl-custom-values.yaml charts/stable/scalardl
```

## Upgrade Scalar DL 

 ```console
# upgrade schema release load-schema with new revision
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade load-schema charts/stable/schema-loading --namespace default -f conf/schema-loading-custom-values.yaml

# upgrade scalardl release prod with new revision
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade prod charts/stable/scalardl --namespace default -f conf/scalardl-custom-values.yaml
```
Note: 

`helm ls -a` command can be used to list currently installed releases
      
## Remove Scalar DL 

```console
# Remove loaded schema with release name load-schema  
$ cd ${SCALAR_K8S_HOME}
$ helm delete load-schema 

# Remove scalardl with release name prod   
$ cd ${SCALAR_K8S_HOME}
$ helm delete prod 
```

## Configuration

See the [Configurations](../charts/stable/scalardl/README.md) used in the Charts  
 