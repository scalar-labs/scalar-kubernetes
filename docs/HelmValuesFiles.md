# How to customize values for Scalar DL and Schema Loading Helm charts

In `${SCALAR_K8S_CONFIG_DIR}` contain the helm custom values use for deploying the application in Kubernetes.

The default values are described here:

* [scalardl](../charts/stable/scalardl/README.md)
* [schema-loading](../charts/stable/schema-loading/README.md)

Once you change the value on your local machine, you need to re-apply the deployment.

## Configure Database

Scalar DL uses Cassandra as a backend database by default. However, it can optionally use Cosmos DB instead of Cassandra when you deploy on Azure.

### Cassandra

If you created the Cassandra resources with the default domain name and the default credentials of [How to Create Azure AKS with scalar-terraform](AKSScalarTerraformDeploymentGuide.md), you can use `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml` and `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml` as they are. If you used a different configuration for Cassandra, please update the files as needed.

### Cosmos DB

To configure Scalar DL to work with Cosmos DB, `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml` and `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml` files need to be updated to set the information about a Cosmos DB deployment as described below.

First, get the endpoint and the master key of your Cosmos DB account. If you [deployed a Cosmos DB account with scalar-terraform](./AKSScalarTerraformDeploymentGuide.md#create-database-resources), you can get them by running `terraform output` in the `cosmosdb` module:

```console
$ cd ${SCALAR_TERRAFORM_EXAMPLES}/azure/cosmosdb
$ terraform output
cosmosdb_account_endpoint = https://example-k8s-azure-b8ci1si-cosmosdb.documents.azure.com:443/
cosmosdb_account_primary_master_key = <PRIMARY_MASTER_KEY>
cosmosdb_account_secondary_master_key = ...
```

And open `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml`, change the value of `database` to `cosmos`, and update the values of `contactPoints` and `password` with the ones you got above respectively.

```yaml
schemaLoading:
  database: cosmos
  contactPoints: https://example-k8s-azure-b8ci1si-cosmosdb.documents.azure.com:443/
  password: <PRIMARY_MASTER_KEY>
  cosmosBaseResourceUnit: "400"
```

Finally, open `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml` and uncomment `dbContactPoints`, `dbPassword`, `dbStorage` and update the values of the `scalarLedgerConfiguration`.

```yaml
  scalarLedgerConfiguration:
    dbContactPoints: https://example-k8s-azure-b8ci1si-cosmosdb.documents.azure.com:443/
    # dbContactPort: null
    # dbUsername: ""
    dbPassword: <PRIMARY_MASTER_KEY>
    dbStorage: cosmos
```

## Increase the number of Envoy Pods

In `scalardl-custom-values.yaml`, you can update the number of replicaCount to the desired number of pod

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
envoy:
  replicaCount: 6
```

The number of deployable pods depends on the number of available nodes. So, you may need to increase the number of nodes with Terraform.

## Increase the resource of Envoy Pods

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

## Expose `Envoy` endpoint to public

In `scalardl-custom-values.yaml`, you can remove `annotations` to expose `Envoy`

```yml
envoy:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
      service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "k8s_ingress"
```

## Increase the number of Ledger Pods

In `scalardl-custom-values.yaml`, you can update `replicaCount` to the desired number of pods.

edit `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml`

```yml
ledger:
  replicaCount: 6
```

The number of deployable pods depends on the number of available nodes. You may need to increase the number of nodes with Terraform.

## Increase the resource of Ledger Pods

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

In `scalardl-custom-values.yaml` and `schema-loading-custom-values.yaml`, you can update the internal domain as follows.

Open `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml` and update the value of `dbContactPoints`.

```yml
ledger:
  scalarLedgerConfiguration:
    dbContactPoints: cassandra-lb.internal.scalar-labs.com
```

Please don't forget to change the schema internal domain in `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml`.

```yml
cassandra:
  contactPoints: cassandra-lb.internal.scalar-labs.com
```

Note: If the internal_domain var is not correct or the Cassandra is not fully started, the schema loading job can fail. You will get the following error

```console
TASK [scalardl : Check Schema Loading job have been successful] **********************************************************************************************************************************************************
FAILED - RETRYING: Check Schema Loading job have been successful (10 retries left).
FAILED - RETRYING: Check Schema Loading job have been successful (9 retries left).
...
FAILED - RETRYING: Check Schema Loading job have been successful (1 retries left).
fatal: [bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com]: FAILED!
```
