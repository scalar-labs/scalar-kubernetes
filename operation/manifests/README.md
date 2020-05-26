# Scalar Ledger

## Requirements

* kubectl version 1.5.10
* Helm version 2.16.3
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.
* deploy terraform k8s from this repository

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

Kubectl tool install instructions can be found [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

#### Install kubectl

```console
asdf plugin-add kubectl
asdf install kubectl 1.15.10
asdf global kubectl 1.15.10
```

#### Verify kubectl

```console
kubectl version
```

you should get:

```console
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.7", GitCommit:"6c143d35bb11d74970e7bc0b6c45b6bfdffc0bd4", GitTreeState:"clean", BuildDate:"2019-12-11T12:42:56Z", GoVersion:"go1.12.12", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.10", GitCommit:"059c666b8d0cce7219d2958e6ecc3198072de9bc", GitTreeState:"clean", BuildDate:"2020-04-03T15:17:29Z", GoVersion:"go1.12.12", Compiler:"gc", Platform:"linux/amd64"}
```

### Start Scalar-Ledger

#### docker registry setting up

setup the docker registry on kubernetes

```console
kubectl create secret docker-registry reg-docker-secrets \
  --docker-server=<your-registry-server> \
  --docker-username=<your-name> \
  --docker-password=<your-pword> \
```

#### deploy Scalar-Ledger

it is time to deploy our scalar-ledger

to deploy scalar-ledger app with kubectl

```console
kubectl create -f ledger/
configmap/scalar-ledger created
deployment.extensions/scalar-ledger created
service/scalar-ledger-headless created
```

to deploy envoy proxy with kubectl

```console
kubectl create -f envoy/
configmap/envoy created
deployment.extensions/envoy created
service/envoy created
```

check the status of the pods and services

```console
kubectl get po,svc
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

now you can run kelpie or scalar-samples project to try out.
