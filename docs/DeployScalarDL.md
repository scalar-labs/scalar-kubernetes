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

# Please update `/path/to/local-repository-config-dir` before running the command.
$ export SCALAR_K8S_CONFIG_DIR=/path/to/local-repository-config-dir

$ cd ${SCALAR_K8S_HOME}
$ ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini operation/playbook-deploy-scalardl.yml

PLAY [Deploy scalar ledger and envoy in kubernetes] *********************************************************************************************************************************************************

[OMIT]

PLAY RECAP **************************************************************************************************************************************************************************************************
bastion-example-k8s-azure-ukkpigy.eastus.cloudapp.azure.com : ok=12   changed=0    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0
```

You can check if the pods and the services are properly deployed as follows.

```console
$ kubectl get po,svc,endpoints,node -o wide
NAME                                    READY   STATUS      RESTARTS   AGE   IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/se-scalar-envoy-7ddff6fdc5-6zhv2    1/1     Running     0          39m   10.42.41.109   aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/se-scalar-envoy-7ddff6fdc5-82nvj    1/1     Running     0          39m   10.42.40.127   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/se-scalar-envoy-7ddff6fdc5-cwhtb    1/1     Running     0          39m   10.42.40.252   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/sl-scalar-ledger-846d69ddf5-6rcbq   1/1     Running     0          39m   10.42.40.161   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/sl-scalar-ledger-846d69ddf5-72nln   1/1     Running     0          39m   10.42.40.243   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/sl-scalar-ledger-846d69ddf5-clvwx   1/1     Running     0          39m   10.42.41.101   aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/sl-scalar-ledger-schema-fkkp5       0/1     Completed   0          39m   10.42.40.40    aks-default-34802672-vmss000000        <none>           <none>

NAME                                TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                           AGE   SELECTOR
service/kubernetes                  ClusterIP      10.42.48.1     <none>        443/TCP                           65m   <none>
service/se-scalar-envoy             LoadBalancer   10.42.50.139   10.42.44.4    50051:30731/TCP,50052:32075/TCP   39m   app.kubernetes.io/instance=se,app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=1.0.0
service/se-scalar-envoy-metrics     ClusterIP      10.42.50.195   <none>        9001/TCP                          39m   app.kubernetes.io/instance=se,app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=1.0.0
service/sl-scalar-ledger-headless   ClusterIP      None           <none>        <none>                            39m   app.kubernetes.io/instance=sl,app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=2.0.7

NAME                                  ENDPOINTS                                                              AGE
endpoints/kubernetes                  10.42.40.4:443                                                         65m
endpoints/se-scalar-envoy             10.42.40.127:50052,10.42.40.252:50052,10.42.41.109:50052 + 3 more...   39m
endpoints/se-scalar-envoy-metrics     10.42.40.127:9001,10.42.40.252:9001,10.42.41.109:9001                  39m
endpoints/sl-scalar-ledger-headless   10.42.40.161,10.42.40.243,10.42.41.101                                 39m
```

The private endpoint is 10.42.44.4 on port 50051 and 50052

## Customize values for scalar-ledger and scalar-envoy charts

In `${SCALAR_K8S_CONFIG_DIR}/example` contain the helm custom values use for deploying the application in Kubernetes.

The default values are describe in here:

* [scalar-envoy](../charts/stable/scalar-envoy/README.md)
* [scalar-ledger](../charts/stable/scalar-ledger/README.md)

Once you change the value on your local machine, you need to re-apply the deployment `ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini operation/playbook-deploy-scalardl.yml`

### How to increase the number of Envoy Pod

In `envoy-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_CONFIG_DIR}/envoy-custom-values.yaml`

```yml
replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

### How to increase the resource of Envoy Pod

In `envoy-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_CONFIG_DIR}/envoy-custom-values.yaml`

```yml
resources:
  requests:
    cpu: 400m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 328Mi
```

More information can be found in [the official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)

### How to expose `scalar-envoy` endpoint to public

In `envoy-custom-values.yaml`, you can remove `annotations` to expose `scalar-envoy`

```yml
service:
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "k8s_ingress"
```

### How to increase the number of Ledger Pod

In `ledger-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_CONFIG_DIR}/ledger-custom-values.yaml`

```yml
replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

### How to increase the resource of Ledger Pod

In `ledger-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_CONFIG_DIR}/ledger-custom-values.yaml`

```yml
resources:
  requests:
    cpu: 1500m
    memory: 2Gi
  limits:
    cpu: 1600m
    memory: 4Gi
```

More information can be found in [the official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)
