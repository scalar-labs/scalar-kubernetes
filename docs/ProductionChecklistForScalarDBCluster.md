# Production checklist for ScalarDB Cluster

This document explains the recommendations of ScalarDB Cluster for production deployment.

## Before you begin

We assume that you deploy ScalarDB Cluster on managed Kubernetes cluster which is recommended way.

## ScalarDB Cluster

### Number of pods and Kubernetes worker nodes

To ensure that the Kubernetes cluster has high availability, you should use at least three worker nodes in three availability zones and deploy at least three pods. You also should ensure that deploying one pod on one worker node by using [Node Affinity](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/).


### Worker node spec

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

## Client application of ScalarDB Cluster

### Configuration of the transaction manager

You must always run the CRUD requests via ScalarDB Cluster. Please check your client's properties file that includes the configuration `scalar.db.transaction_manager=cluster`.

* Recommended in production
  ```console
  [App (ScalarDB Cluster Library with gRPC)] ---> [ScalarDB Cluster (ScalarDB Library with Consensus Commit)] ---> [Underlying storage/database]
  ```
* Not recommended in production (Testing purpose only)
  ```console
  [App (ScalarDB Cluster Library with Consensus Commit)] ---> [Underlying storage/database]
  ```

### Deployment of client application with `direct-kubernetes` client mode

If you use the [`direct-kubernetes` client mode](https://github.com/scalar-labs/scalardb-cluster/blob/main/docs/developer-guide-for-scalardb-cluster-with-java-api.md#direct-kubernetes-client-mode), you have to deploy your client application on the same Kubernetes cluster as ScalarDB Cluster deployment.

And, you must deploy additional Kubernetes resources to make your client application work properly.  For details, see [Deploy your client application on Kubernetes with `direct-kubernetes` mode](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalardb-cluster.md#deploy-your-client-application-on-kubernetes-with-direct-kubernetes-mode).

### Transaction handling

In your application, you must make sure it always runs [`commit()`](https://javadoc.io/static/com.scalar-labs/scalardb/3.10.0/com/scalar/db/api/DistributedTransaction.html#commit--) or [rollback()](https://javadoc.io/static/com.scalar-labs/scalardb/3.10.0/com/scalar/db/api/DistributedTransaction.html#rollback--) after you [begin()](https://javadoc.io/static/com.scalar-labs/scalardb/3.10.0/com/scalar/db/api/DistributedTransactionManager.html#begin--) a transaction. If you miss running `commit()` or `rollback()`, it might cause unexpected issues or reading inconsistency data from the backend database.

### Exception handling

In your application, you must make sure it handles transaction exceptions. For details, see [Handle exceptions](https://github.com/scalar-labs/scalardb/blob/master/docs/api-guide.md#handle-exceptions).
