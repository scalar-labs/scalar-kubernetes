# Production checklist for ScalarDB Cluster

This checklist provides recommendations when deploying ScalarDB Cluster in a production environment.

## Before you begin

In this checklist, we assume that you are deploying ScalarDB Cluster on a managed Kubernetes cluster, which is recommended.

## Production checklist: ScalarDB Cluster

The following is a checklist of recommendations when setting up ScalarDB Cluster in a production environment.

### Number of pods and Kubernetes worker nodes

To ensure that the Kubernetes cluster has high availability, you should use at least three worker nodes in three availability zones and deploy at least three pods. You also should ensure that one pod is deployed on one worker node by using [Node Affinity](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/).

### Worker node specifications

From the perspective of commercial licenses, resources for one pod running ScalarDB Cluster are limited to 2vCPU / 4GB memory. In addition, we recommend deploying one ScalarDB Cluster pod and one Envoy pod on one worker node. Note that you do not need to deploy an Envoy pod when using `direct-kubernetes` mode.

In other words, the following components run on one worker node:

* ScalarDB Cluster pod (2vCPU / 4GB)
* Envoy proxy (0.2–0.3 vCPU / 256–328 MB)
* Kubernetes components

With this in mind, you should use a worker node that has 4vCPU / 8GB memory resources. We recommend running only the above components on the worker node for ScalarDB Cluster.

### Network

You should create the Kubernetes cluster on a private network since ScalarDB Cluster does not provide any services to users directly via internet access. We recommend accessing ScalarDB Cluster via a private network from your applications.

### Monitoring and logging

You should monitor the deployed components and collect their logs. For details, see [Monitoring Scalar products on a Kubernetes cluster](./K8sMonitorGuide.md) and [Collecting logs from Scalar products on a Kubernetes cluster](./K8sLogCollectionGuide.md).

### Backup and restore

You should enable the automatic backup feature and PITR feature in the backend database. For details, see [Set up a database for ScalarDB/ScalarDL deployment](./SetupDatabase.md).

## Production checklist: Client applications that access ScalarDB Cluster

The following is a checklist of recommendations when setting up a client application that accesses ScalarDB Cluster in a production environment.

### Transaction manager configuration

You must always access ScalarDB Cluster. To ensure requests are running properly, check the properties file for your client application and confirm that `scalar.db.transaction_manager=cluster` is configured.

* Recommended for production environments
  ```mermaid
  flowchart LR
    A(<b>App</b> <br> ScalarDB Cluster Library with gRPC) --> B(<b>ScalarDB Cluster</b> <br> ScalarDB Library with Consensus Commit) --> C(Underlying storage/database)
  ```

* Not recommended for production environments (for testing purposes only)
  ```mermaid
  flowchart LR
    A(<b>App</b> <br> ScalarDB Cluster Library with Consensus Commit) --> B(Underlying storage/database)
  ```

### Deployment of the client application when using `direct-kubernetes` client mode

If you use [`direct-kubernetes` client mode](https://github.com/scalar-labs/scalardb-cluster/blob/main/docs/developer-guide-for-scalardb-cluster-with-java-api.md#direct-kubernetes-client-mode), you must deploy your client application on the same Kubernetes cluster as the ScalarDB Cluster deployment.

Also, when using `direct-kubernetes` client mode, you must deploy additional Kubernetes resources to make your client application work properly.  For details, see [Deploy your client application on Kubernetes with `direct-kubernetes` mode](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalardb-cluster.md#deploy-your-client-application-on-kubernetes-with-direct-kubernetes-mode).

### Transaction handling

You must make that sure your application always runs [`commit()`](https://javadoc.io/static/com.scalar-labs/scalardb/3.10.0/com/scalar/db/api/DistributedTransaction.html#commit--) or [`rollback()`](https://javadoc.io/static/com.scalar-labs/scalardb/3.10.0/com/scalar/db/api/DistributedTransaction.html#rollback--) after you [`begin()`](https://javadoc.io/static/com.scalar-labs/scalardb/3.10.0/com/scalar/db/api/DistributedTransactionManager.html#begin--) a transaction. If the application does not run `commit()` or `rollback()`, your application might experience unexpected issues or read inconsistent data from the backend database.

### Exception handling

You must make sure that your application handles transaction exceptions. For details, see [Handle exceptions](https://github.com/scalar-labs/scalardb/blob/master/docs/api-guide.md#handle-exceptions).
