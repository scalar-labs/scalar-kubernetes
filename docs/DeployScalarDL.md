# How to deploy Scalar DL on kubernetes with Ansible

This document explains how to deploy Scalar Ledger and Envoy on Kubernetes with Ansible. After following the doc, you will be able to use Scalar Ledger inside Kubernetes

## Requirements

* Have install tool into the bastion [More information can be found here](./PrepareBastionTool.md)
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.
Note that Kubernetes cluster needs to be set up properly in advance. This can be easily done with the [terraform module](../../docs/README.md)

## Preparation

You need set `DOCKERHUB_USER` and `DOCKERHUB_ACCESS_TOKEN` as env or set the values directly in the `playbook-deploy-scalardl.yml` for `docker_username` and `docker_password`.

```console
export DOCKERHUB_USER=<user>
export DOCKERHUB_ACCESS_TOKEN=<token>
```

Note: You can confirmed the env are correctly set with `export` command

## Deploy Scalar DL

It is now ready to deploy Scalar DL to the k8s cluster.

```console
# Please update `/path/to/local-repository` before running the command.
export SCALAR_K8S_HOME=/path/to/local-repository
cd ${SCALAR_K8S_HOME}/operation
ansible-playbook -i inventory.ini playbook-deploy-scalardl.yml

PLAY [Deploy scalar ledger and envoy in kubernetes] *********************************************************************************************************************************************************

[OMIT]

PLAY RECAP **************************************************************************************************************************************************************************************************
bastion-paul-k8s-azure-ukkpigy.eastus.cloudapp.azure.com : ok=12   changed=0    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0
```

You can check if the pods and the services are properly deployed as follows.

```console
[centos@bastion-1 manifests]$ kubectl get po,svc -o wide
NAME                                 READY   STATUS      RESTARTS   AGE    IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/envoy-7754bd6568-5pchd           1/1     Running     0          20m    10.42.40.224   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/envoy-7754bd6568-gxvxb           1/1     Running     0          20m    10.42.41.7     aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/envoy-7754bd6568-zfn6b           1/1     Running     0          20m    10.42.40.242   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-866c4bd6bb-2qh5l   1/1     Running     0          20m    10.42.40.247   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-866c4bd6bb-8sstt   1/1     Running     0          20m    10.42.41.24    aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-866c4bd6bb-jl9cm   1/1     Running     0          20m    10.42.41.15    aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalardl-schema-txhq6            0/1     Completed   0          32m    10.42.41.8     aks-scalardlpool-34802672-vmss000001   <none>           <none>

NAME                             TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                           AGE     SELECTOR
service/envoy                    LoadBalancer   10.42.51.101   52.224.73.93   50051:30282/TCP,50052:30946/TCP   20m     app.kubernetes.io/name=envoy,app.kubernetes.io/version=v1.14.1
service/kubernetes               ClusterIP      10.42.48.1     <none>         443/TCP                           7h34m   <none>
service/scalar-ledger-headless   ClusterIP      None           <none>         <none>                            20m     app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=v2.0.5
```
