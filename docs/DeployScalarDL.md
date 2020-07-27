# How to deploy Scalar DL on Kubernetes with Ansible

This document explains how to deploy Scalar Ledger and Envoy on Kubernetes with Ansible. After following the doc, you will be able to use Scalar Ledger inside Kubernetes.

## Requirements

* Have completed the [How to install Kubernetes CLI and Helm on the bastion](./PrepareBastionTool.md)
* An authority to pull `scalarlabs/scalar-ledger` docker repository.
  * `scalar-ledger` is available to only our partners and customers at the moment.

Note that the Kubernetes cluster needs to be set up properly in advance. This can be easily done with the [Terraform module](../../docs/README.md)

## Preparation

You need set `DOCKERHUB_USER` and `DOCKERHUB_ACCESS_TOKEN` as env or set the values directly in the `playbook-deploy-scalardl.yml` for `docker_username` and `docker_password`.

```console
$ export DOCKERHUB_USER=<user>
$ export DOCKERHUB_ACCESS_TOKEN=<token>
```

## Deploy Scalar DL

It is now ready to deploy Scalar DL to the k8s cluster.

```console
# Please update `/path/to/local-repository` before running the command.
$ export SCALAR_K8S_HOME=/path/to/local-repository
$ cd ${SCALAR_K8S_HOME}/operation
$ ansible-playbook -i inventory.ini playbook-deploy-scalardl.yml

PLAY [Deploy scalar ledger and envoy in kubernetes] *********************************************************************************************************************************************************

[OMIT]

PLAY RECAP **************************************************************************************************************************************************************************************************
bastion-example-k8s-azure-ukkpigy.eastus.cloudapp.azure.com : ok=12   changed=0    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0
```

You can check if the pods and the services are properly deployed as follows.

```console
$ kubectl get po,svc,endpoints -o wide
NAME                                 READY   STATUS      RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/scalar-envoy-56c9cc4598-dwkvl    1/1     Running     0          2m14s   10.42.41.4     aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-envoy-56c9cc4598-dz6mr    1/1     Running     0          7m24s   10.42.41.37    aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-envoy-56c9cc4598-z6szw    1/1     Running     0          4m39s   10.42.40.245   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-6f895669bb-c5567   1/1     Running     0          25m     10.42.41.8     aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-6f895669bb-hzp4p   1/1     Running     0          25m     10.42.41.33    aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-6f895669bb-wqn27   1/1     Running     0          25m     10.42.40.215   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalardl-schema-bt7zx            0/1     Completed   0          25m     10.42.40.221   aks-default-34802672-vmss000000        <none>           <none>

NAME                             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                           AGE     SELECTOR
service/kubernetes               ClusterIP      10.42.48.1     <none>          443/TCP                           89m     <none>
service/scalar-envoy             LoadBalancer   10.42.49.207   52.142.18.158   50051:32102/TCP,50052:32723/TCP   24m     app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=v1.0.0
service/scalar-envoy-metrics     ClusterIP      10.42.49.217   <none>          9001/TCP                          4m26s   app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=v1.0.0
service/scalar-ledger-headless   ClusterIP      None           <none>          <none>                            24m     app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=v2.0.7

NAME                               ENDPOINTS                                                           AGE
endpoints/kubernetes               10.42.40.4:443                                                      89m
endpoints/scalar-envoy             10.42.40.245:50052,10.42.41.37:50052,10.42.41.4:50052 + 3 more...   24m
endpoints/scalar-envoy-metrics     10.42.40.245:9001,10.42.41.37:9001,10.42.41.4:9001                  4m26s
endpoints/scalar-ledger-headless   10.42.40.215,10.42.41.33,10.42.41.8                                 24m
```

## Customize values for scalar-ledger and scalar-envoy charts

In `${SCALAR_K8S_HOME}/operation/config` contain the helm custom values use for deploying the application in Kubernetes.

The default values are describe in here:

* [scalar-envoy](../charts/stable/scalar-envoy/README.md)
* [scalar-ledger](../charts/stable/scalar-ledger/README.md)

Once you change the value on your local machine, you need to re-apply the deployment `ansible-playbook -i inventory.ini playbook-deploy-scalardl.yml`

### How to increase the number of Envoy Pod

In `envoy-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_HOME}/operation/config/envoy-custom-values.yaml`

```yaml
replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

### How to increase the resource of Envoy Pod

In `envoy-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_HOME}/operation/config/envoy-custom-values.yaml`

```yaml
resources:
  requests:
    cpu: 400m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 328Mi
```

More information can be found in [the official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)

### How to increase the number of Ledger Pod

In `ledger-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_HOME}/operation/config/ledger-custom-values.yaml`

```yaml
replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

### How to increase the resource of Ledger Pod

In `ledger-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_HOME}/operation/config/ledger-custom-values.yaml`

```yaml
resources:
  requests:
    cpu: 1500m
    memory: 2Gi
  limits:
    cpu: 1600m
    memory: 4Gi
```

More information can be found in [the official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)
