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

# Please update `/path/to/local-repository` before running the command.
$ export SCALAR_K8S_HOME=/path/to/local-repository

# Please update `/path/to/local-repository-config-dir` before running the command.
$ export SCALAR_K8S_CONFIG_DIR=/path/to/local-repository-config-dir
```

Copy from `conf` directory to `${SCALAR_K8S_CONFIG_DIR}`

```console
$ cp ${SCALAR_K8S_HOME}/conf/{scalardl-custom-values.yaml,schema-loading-custom-values.yaml} ${SCALAR_K8S_CONFIG_DIR}/
```

## Deploy Scalar DL

It is now ready to deploy Scalar DL to the k8s cluster.

```console
$ cd ${SCALAR_K8S_HOME}
$ ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini operations/playbook-deploy-scalardl.yml
PLAY [Deploy Scalar Ledger and Envoy in Kubernetes] *****************************************************************************************************************************************************************************************************

TASK [scalardl : Create directory on remote server] *****************************************************************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]

TASK [scalardl : Copy helm charts] **********************************************************************************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]

TASK [scalardl : Copy helm charts custom values] ********************************************************************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com] => (item=scalardl-custom-values.yaml)
changed: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com] => (item=schema-loading-custom-values.yaml)

TASK [scalardl : Check if docker-registry secrets exists in Kubernetes] *********************************************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]

TASK [scalardl : Add docker-registry secrets in Kubernetes] *********************************************************************************************************************************************************************************************
skipping: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]

TASK [scalardl : Deploy Scalar Schema] ******************************************************************************************************************************************************************************************************************
changed: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]

TASK [scalardl : Wait until completion] *****************************************************************************************************************************************************************************************************************
FAILED - RETRYING: Wait until completion (10 retries left).
ok: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]

TASK [scalardl : Deploy Scalar DL] **********************************************************************************************************************************************************************************************************************
changed: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com : ok=7    changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

You can check if the pods and the services are properly deployed as follows.

```console
$ kubectl get po,svc,endpoints -o wide
NAME                                             READY   STATUS      RESTARTS   AGE   IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/load-schema-schema-loading-cassandra-4rq96   0/1     Completed   0          29m   10.42.40.55    aks-default-34802672-vmss000000        <none>           <none>
pod/prod-scalardl-envoy-568f9cbff9-brrq2         1/1     Running     0          29m   10.42.40.219   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/prod-scalardl-envoy-568f9cbff9-hhw8t         1/1     Running     0          29m   10.42.41.69    aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/prod-scalardl-envoy-568f9cbff9-mqv6t         1/1     Running     0          29m   10.42.40.137   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/prod-scalardl-ledger-55d96b74f8-htdk7        1/1     Running     0          29m   10.42.41.17    aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/prod-scalardl-ledger-55d96b74f8-p4ck7        1/1     Running     0          29m   10.42.41.108   aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/prod-scalardl-ledger-55d96b74f8-ptr4d        1/1     Running     0          29m   10.42.40.108   aks-scalardlpool-34802672-vmss000000   <none>           <none>

NAME                                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                           AGE     SELECTOR
service/kubernetes                      ClusterIP      10.42.48.1     <none>        443/TCP                           7h17m   <none>
service/prod-scalardl-envoy             LoadBalancer   10.42.50.35    10.42.44.4    50051:30459/TCP,50052:30431/TCP   29m     app.kubernetes.io/app=envoy,app.kubernetes.io/instance=prod,app.kubernetes.io/name=scalardl
service/prod-scalardl-envoy-metrics     ClusterIP      10.42.50.247   <none>        9001/TCP                          29m     app.kubernetes.io/app=envoy,app.kubernetes.io/instance=prod,app.kubernetes.io/name=scalardl
service/prod-scalardl-ledger-headless   ClusterIP      None           <none>        <none>                            29m     app.kubernetes.io/app=ledger,app.kubernetes.io/instance=prod,app.kubernetes.io/name=scalardl

NAME                                      ENDPOINTS                                                             AGE
endpoints/kubernetes                      10.42.40.4:443                                                        7h17m
endpoints/prod-scalardl-envoy             10.42.40.137:50052,10.42.40.219:50052,10.42.41.69:50052 + 3 more...   29m
endpoints/prod-scalardl-envoy-metrics     10.42.40.137:9001,10.42.40.219:9001,10.42.41.69:9001                  29m
endpoints/prod-scalardl-ledger-headless   10.42.40.108,10.42.41.108,10.42.41.17                                 29m
```

The private endpoint is 10.42.44.4 on port 50051 and 50052

## Customize values for scalardl-ledger and scalardl-envoy charts

In `${SCALAR_K8S_CONFIG_DIR}` contain the helm custom values use for deploying the application in Kubernetes.

The default values are describe in here:

* [scalardl](../charts/stable/scalardl/README.md)

Once you change the value on your local machine, you need to re-apply the deployment `ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini operations/playbook-deploy-scalardl.yml`

### How to increase the number of Envoy Pod

In `scalardl-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
envoy:
  replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

### How to increase the resource of Envoy Pod

In `scalardl-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
envoy:
  resources:
    requests:
      cpu: 400m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 328Mi
```

More information can be found in [the official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)

### How to expose `Envoy` endpoint to public

In `scalardl-custom-values.yaml`, you can remove `annotations` to expose `Envoy`

```yml
envoy:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
      service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "k8s_ingress"
```

### How to increase the number of Ledger Pod

In `scalardl-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
ledger:
  replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

### How to increase the resource of Ledger Pod

In `scalardl-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
ledger:
  resources:
    requests:
      cpu: 1500m
      memory: 2Gi
    limits:
      cpu: 1600m
      memory: 4Gi
```

More information can be found in [the official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)

## Use a different internal domain

In `scalardl-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
ledger:
  scalarLedgerConfiguration:
    cassandraHost: cassandra-lb.internal.scalar-labs.com
```

don't forget to change the schema internal domain in `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml`

```yml
cassandra:  
  host: cassandra-lb.internal.scalar-labs.com
```
