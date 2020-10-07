## Deploy Scalar DL using Helm Chart

This document explains how to deploy Scalar Ledger and Envoy on Kubernetes . After following the doc, you will be able to use Scalar Ledger inside Kubernetes.

### Requirements

* Install Kubectl and Helm in the system which is being used to access the kubernetes cluster.
* An authority to pull `scalarlabs/scalar-ledger` and `scalarlabs/scalardl-schema-loader-cassandra` docker repositories.
  * `scalar-ledger` and `scalardl-schema-loader-cassandra` are available to only our partners and customers at the moment.

Note that the Kubernetes cluster needs to be set up properly in advance. This can be easily done with the [Terraform module](../../docs/README.md)

### Preparation
Prepare environment variables for easy access and add docker registry secrets in kubernetes

```console
# Please update `/path/to/local-repository` before running the command.
$ export SCALAR_K8S_HOME=/path/to/local-repository

# Prepare kubeconfig file
$ cd ${SCALAR_K8S_HOME}/examples/azure/kubernetes/
$ terraform output kube_config > ~/.kube/config

# Create docker registry secrets in kubernetes
$ kubectl create secret docker-registry reg-docker-secrets --docker-server=https://index.docker.io/v2/ --docker-username=<dockerhub-username> --docker-password=<dockerhub-access-token>
```

### Installing Scalar DL Resources on Kubernetes with Helm Chart

 ```console
# Install scalardl and envoy
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade --install prod charts/stable/scalardl --namespace default -f conf/scalardl-custom-values.yaml

# Load Schema after scalar dl installation 
$ cd ${SCALAR_K8S_HOME}
$ helm upgrade --install load-schema charts/stable/schema-loading --namespace default -f conf/schema-loading-custom-values.yaml
```
### Removing Scalar DL resources from Kubernetes 
```console
$ cd ${SCALAR_K8S_HOME}
$ helm delete prod 
``` 
 
   
   
   
   
   
   
   
   
   
    
    
