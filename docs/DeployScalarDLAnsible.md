# How to deploy Scalar DL on Kubernetes with Ansible

This document explains how to deploy Scalar Ledger and Envoy on Kubernetes with Ansible. After following the doc, you will be able to use Scalar Ledger inside Kubernetes.

## Requirements

* Have completed the [How to install Kubernetes CLI and Helm on the bastion](./PrepareBastionTool.md)
* An authority to pull `scalarlabs/scalar-ledger` and `scalarlabs/scalardl-schema-loader` docker repositories.
  * `scalar-ledger` and `scalardl-schema-loader` are available to only our partners and customers at the moment.

## Preparation

You need set `DOCKERHUB_USER` and `DOCKERHUB_ACCESS_TOKEN` as env or set the values directly in the `playbook-deploy-scalardl.yml` for `docker_username` and `docker_password`.

```console
export DOCKERHUB_USER=<user>
export DOCKERHUB_ACCESS_TOKEN=<token>
```

Copy from `conf` directory to `${SCALAR_K8S_CONFIG_DIR}`

```console
$ cp ${SCALAR_K8S_HOME}/conf/{scalardl-custom-values.yaml,schema-loading-custom-values.yaml} ${SCALAR_K8S_CONFIG_DIR}/
```

## Configure Database

Scalar DL uses Cassandra as a backend database by default. However, it can optionally use Cosmos DB instead of Cassandra when you deploy on Azure.

### Casandra

If you created the Cassandra resources with the default domain name and the default credentials of [How to Create Azure AKS with scalar-terraform](AKSScalarTerraformDeploymentGuide.md), you can use `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml` and `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml` as they are. If you used a different configuration for Cassandra, please update the files as needed.

### Cosmos DB

To configure Scalar DL to work with Cosmos DB, `${SCALAR_K8S_CONFIG_DIR}/schema-loading-custom-values.yaml` and `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml` files need to be updated to set the information about a Cosmos DB deployment as described below.

First, get the endpoint and the master key of your Cosmos DB account. If you [deployed a Cosmos DB account with scalar-terraform](./AKSScalarTerraformDeploymentGuide.md#create-database-resources), you can get them by running `terraform output` in the `cosmosdb` module:

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/cosmosdb
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
  image:
    repository: scalarlabs/scalardl-schema-loader
    version: 1.0.0
    pullPolicy: IfNotPresent
```

Finally, open `${SCALAR_K8S_CONFIG_DIR}/scalardl-custom-values.yaml` and uncomment and update the values of the `scalarLedgerConfiguration`.

```yaml
  scalarLedgerConfiguration:
    dbContactPoints: https://example-k8s-azure-b8ci1si-cosmosdb.documents.azure.com:443/
    dbContactPort: null
    dbUsername: ""
    dbPassword: <PRIMARY_MASTER_KEY>
    dbStorage: cosmos
```

## Deploy Scalar DL

It is now ready to deploy Scalar DL to the k8s cluster.

```console
$ cd ${SCALAR_K8S_HOME}
$ ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini playbooks/playbook-deploy-scalardl.yml
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

Note: To further customize the Helm charts used in the Ansible playbook to deploy Scalar DL and Envoy, please refer to [How to customize values for Scalar DL and Schema Loading charts](./HelmChartsCustomization.md).
