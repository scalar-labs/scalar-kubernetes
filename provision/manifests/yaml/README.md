# Scalar Ledger - Minikube

## Requirements

* kubectl version 1.5.10
* Minikube version 1.9.2
* Helm version 2.16.3
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.

## Setup the requirements

This guide will cover `howto` install tools for setting up your environment with asdf.

### ASDF (Manage multiple runtime versions with a single CLI tool)
* [asdf](https://asdf-vm.com/#/)

On OSX and Linux

```console
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.7
```

For Bash

```console
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

For Zsh

```console
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
```

To see all the version

```console
asdf list
helm
  2.16.3
kubectl
  1.15.10
minikube
  1.9.2
```

### kubectl

Kubectl tool install instructions can be found here: https://kubernetes.io/docs/tasks/tools/install-kubectl/

#### Install kubectl

```console
asdf plugin-add kubectl
asdf install kubectl 1.15.7
asdf global kubectl 1.15.7
```

#### Verify kubectl

```console
kubectl version
```

you should get:

```console
Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.3", GitCommit:"06ad960bfd03b39c8310aaf92d1e7c12ce618213", GitTreeState:"clean", BuildDate:"2020-02-11T18:14:22Z", GoVersion:"go1.13.6", Compiler:"gc", Platform:"darwin/amd64"}
```

### Helm

Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application
instructions can be found here: https://helm.sh/

#### Install Helm

```console
asdf plugin-add helm
asdf install helm 2.16.3
asdf global helm 2.16.3
```

#### Verify Helm

```console
kubectl version
```

v
```console
helm version
Client: &version.Version{SemVer:"v2.16.3", GitCommit:"1ee0254c86d4ed6887327dabed7aa7da29d7eb0d", GitTreeState:"clean"}
```

### Minikube

Minikube is a tool that makes it easy to run Kubernetes locally. Minikube runs a single-node Kubernetes cluster inside a Virtual Machine (VM) on your laptop for users looking to try out Kubernetes or develop with it day-to-day.

#### Install Minikube

```console
asdf plugin-add minikube
asdf install minikube 1.9.2
asdf global minikube 1.9.2
```

## Getting Started

### Start minikube

```console
minikube start --kubernetes-version=1.15.10
😄  minikube v1.9.2 on Darwin 10.15.3
✨  Using the hyperkit driver based on existing profile
👍  Kubernetes 1.18.0 is now available. If you would like to upgrade, specify: --kubernetes-version=1.18.0
👍  Starting control plane node m01 in cluster minikube
🔄  Restarting existing hyperkit VM for "minikube" ...
🐳  Preparing Kubernetes v1.15.10 on Docker 19.03.8 ...
🌟  Enabling addons: dashboard, default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube"
```

### Setting up helm

Create the cluster role binding and service account inside k8s

```console
kubectl create -f helm/
```

you should get:

```console
➜  yaml git:(add-scalar-manifests) ✗ kubectl create -f helm/
clusterrolebinding.rbac.authorization.k8s.io/tiller configured
serviceaccount/tiller configured
```

now you can install tiller:

```console
helm init --service-account tiller --upgrade
$HELM_HOME has been configured at $HOME/.helm.
Tiller (the Helm server-side component) has been updated to gcr.io/kubernetes-helm/tiller:v2.16.3 .
```

### Start cassandra inside k8s

for the demo, we re going to use bitnami charts for cassandra, we need to install the bitnami charts repo for helm

```console
helm repo add bitnami https://charts.bitnami.com/bitnami
```

installing from the cassandra

```console
helm upgrade --install cassandra --namespace cassandra --set dbUser.user=cassandra --set dbUser.password=cassandra bitnami/cassandra --version 5.1.2
```

output:

```
Release "cassandra" has been upgraded.
LAST DEPLOYED: Fri Apr 17 15:43:39 2020
NAMESPACE: cassandra
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                     AGE
cassandra-configuration  3h4m
cassandra-init-scripts   1s

==> v1/Pod(related)
NAME         AGE
cassandra-0  3h4m

==> v1/Secret
NAME       AGE
cassandra  3h4m

==> v1/Service
NAME                AGE
cassandra           3h4m
cassandra-headless  3h4m

==> v1/StatefulSet
NAME       AGE
cassandra  3h4m

==> v1beta1/PodDisruptionBudget
NAME                AGE
cassandra-headless  3h4m


NOTES:
** Please be patient while the chart is being deployed **

Cassandra can be accessed through the following URLs from within the cluster:

  - CQL: cassandra.cassandra.svc.cluster.local:9042
  - Thrift: cassandra.cassandra.svc.cluster.local:9160

To get your password run:

   export CASSANDRA_PASSWORD=$(kubectl get secret --namespace cassandra cassandra -o jsonpath="{.data.cassandra-password}" | base64 --decode)

Check the cluster status by running:

   kubectl exec -it --namespace cassandra $(kubectl get pods --namespace cassandra -l app=cassandra,release=cassandra -o jsonpath='{.items[0].metadata.name}') nodetool status

To connect to your Cassandra cluster using CQL:

1. Run a Cassandra pod that you can use as a client:

   kubectl run --namespace cassandra cassandra-client --rm --tty -i --restart='Never' \
   --env CASSANDRA_PASSWORD=$CASSANDRA_PASSWORD \
    \
   --image docker.io/bitnami/cassandra:3.11.6-debian-10-r26 -- bash

2. Connect using the cqlsh client:

   cqlsh -u cassandra -p $CASSANDRA_PASSWORD cassandra

To connect to your database from outside the cluster execute the following commands:

   kubectl port-forward --namespace cassandra svc/cassandra 9042:9042 &
   cqlsh -u cassandra -p $CASSANDRA_PASSWORD 127.0.0.1 9042
```

now you can verify

```console
➜  yaml git:(add-scalar-manifests) ✗ kubectl get po,svc,sts -n cassandra
NAME              READY   STATUS    RESTARTS   AGE
pod/cassandra-0   1/1     Running   1          3h6m

NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                        AGE
service/cassandra            ClusterIP   10.103.118.120   <none>        9042/TCP,9160/TCP                              3h6m
service/cassandra-headless   ClusterIP   None             <none>        7000/TCP,7001/TCP,7199/TCP,9042/TCP,9160/TCP   3h6m

NAME                         READY   AGE
statefulset.apps/cassandra   1/1     3h6m
```

### Start Scalar-Ledger

first create a dedicated namespace for Scalar-Ledger name `scalardlt`

```console
kubectl create -f 00-scalardlt-ns.yaml
namespace/scalardlt created
```

#### build your image

to build docker images of scalar-ledger with grpc_health_probe to help kubernetes know if the container is running fine.

```DockerFile
ARG FROM_SCALAR_IMAGE=scalarlabs/scalar-ledger:2.0.2
FROM ${FROM_SCALAR_IMAGE}

# docs over https://github.com/grpc-ecosystem/grpc-health-probe
RUN GRPC_HEALTH_PROBE_VERSION=v0.3.1 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe
```

and upload it to private hub docker or another private registry

#### docker registry setting up

setup the docker registry on kubernetes

```console
kubectl create secret docker-registry reg-docker-secrets \
  --docker-server=<your-registry-server> \
  --docker-username=<your-name> \
  --docker-password=<your-pword> \
  --docker-email=<your-email>
```

#### deploy Scalar-Ledger

to deploy yaml containing scalar ledger app

```console
kubectl create -f scalardlt/
configmap/scalar-ledger created
deployment.extensions/scalar-ledger created
service/scalar-ledger-headless created
```

to deploy yaml containing envoy proxy

```console
kubectl create -f envoy/
configmap/envoy created
deployment.extensions/envoy created
service/envoy created
```

check the status

```console
kubectl get po,svc -n scalardlt
NAME                                 READY   STATUS    RESTARTS   AGE
pod/envoy-7b58f445cc-2gzsh           1/1     Running   0          9m31s
pod/envoy-7b58f445cc-76ct9           1/1     Running   0          9m31s
pod/envoy-7b58f445cc-mrpf2           1/1     Running   0          9m31s
pod/scalar-ledger-65799f75d8-rpwn5   1/1     Running   0          9m36s
pod/scalar-ledger-65799f75d8-s9phk   1/1     Running   0          9m36s
pod/scalar-ledger-65799f75d8-thvdk   1/1     Running   0          9m36s

NAME                             TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                           AGE
service/envoy                    LoadBalancer   10.102.7.83   <pending>     50051:30165/TCP,50052:30067/TCP   9m31s
service/scalar-ledger-headless   ClusterIP      None          <none>        50051/TCP,50052/TCP               9m36s
```

to expose the service to your localhost machine.

```console
minikube service envoy -n scalardlt
|-----------|-------|-----------------------------|--------------------------------|
| NAMESPACE | NAME  |         TARGET PORT         |              URL               |
|-----------|-------|-----------------------------|--------------------------------|
| scalardlt | envoy | envoy/50051                 | http://192.168.64.3:30165      |
|           |       | envoy-priv/50052            | http://192.168.64.3:30067      |
|-----------|-------|-----------------------------|--------------------------------|
```

now you can run kelpie or scalar-samples project to try out.
