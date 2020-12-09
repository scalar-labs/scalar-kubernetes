# How to customize values for Scalar DL and Schema Loading charts

In `${SCALAR_K8S_CONFIG_DIR}` contain the helm custom values use for deploying the application in Kubernetes.

The default values are described in here:

* [scalardl](../charts/stable/scalardl/README.md)
* [schema-loading](../charts/stable/schema-loading/README.md)

Once you change the value on your local machine, you need to re-apply the deployment.

## How to increase the number of Envoy Pod

In `scalardl-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
envoy:
  replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

## How to increase the resource of Envoy Pod

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

## How to expose `Envoy` endpoint to public

In `scalardl-custom-values.yaml`, you can remove `annotations` to expose `Envoy`

```yml
envoy:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
      service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "k8s_ingress"
```

## How to increase the number of Ledger Pod

In `scalardl-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
ledger:
  replicaCount: 6
```

The number of pods is linked to the number of nodes available. You may need to increase the number of nodes with Terraform

## How to increase the resource of Ledger Pod

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

In `scalardl-custom-values.yaml` and `schema-loading-custom-values.yaml`, you can update resource as follow

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
ledger:
  scalarLedgerConfiguration:
    cassandraHost: cassandra-lb.internal.scalar-labs.com
```

don't forget to change the schema internal domain in `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml`

```yml
cassandra:  
  contactPoints: cassandra-lb.internal.scalar-labs.com
```

Note: If the internal_domain var is not correct or the Cassandra is not fully started, the schema loading job can fail, you will get the following error

```console
TASK [scalardl : Check Schema Loading job have been successful] **********************************************************************************************************************************************************
FAILED - RETRYING: Check Schema Loading job have been successful (10 retries left).
FAILED - RETRYING: Check Schema Loading job have been successful (9 retries left).
[OMIT]
FAILED - RETRYING: Check Schema Loading job have been successful (2 retries left).
FAILED - RETRYING: Check Schema Loading job have been successful (1 retries left).
fatal: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]: FAILED!
```
