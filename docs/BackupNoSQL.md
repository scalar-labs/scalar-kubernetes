# Backup NoSQL database guide

If you use a NoSQL database or multiple databases, you must **pause** the Scalar products to create a transactionally-consistent backup. This guide explains concrete steps of how to create the transactionally-consistent backup of managed databases with the Scalar products on a Kubernetes environment. Please refer to the following document if you want to know more details on the backup way of Scalar products.

* [A Guide on How to Backup and Restore Databases Used Through ScalarDB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md)

In this guide, we assume that using the automatic backup and PITR feature. So, we create a **period** where there are no ongoing transactions for restoring. You can restore data using PITR to the point-in-time in this **period**. Otherwise (if you restore data point-in-time out of this **period**), the restored data becomes inconsistent data and Scalar products don't work properly.

## Backup operations (create the **period** for restoring)

1. Check the pod status before backup.

   You must check the following four points using the `kubectl get pod` command before you start the backup operation.
   * The number of Scalar product pods (You must compare this number with the number after the backup).
   * The Scalar product pod names in the `NAME` column (You must compare these pod names with the pod names after the backup).
   * The Scalar product pod status is `Running` in the `STATUS` column.
   * The restart counts of each pod in the `RESTARTS` column (You must compare these restart counts with the restart counts after the backup).

1. Pause Scalar Product pods using `scalar-admin`.

   Please refer to the [How to use scalar-admin on a Kubernetes environment](./BackupNoSQL.md#how-to-use-scalar-admin-on-a-kubernetes-environment) section in this document for more details on the pause operation.

1. Check the pause completed time.

   You must note the pause completed time to decide the concrete **period** that you can recover data using the PITR feature.

1. Take a backup using the backup feature of each database.

   If you enable the automatic backup and PITR feature, all you have to do is wait for about 10 seconds since the managed databases take backup automatically. This 10 seconds period is the **period** that we can restore data by PITR.

1. Unpause Scalar Product pods using `scalar-admin`.

   Please refer to the [How to use scalar-admin on a Kubernetes environment](./BackupNoSQL.md#how-to-use-scalar-admin-on-a-kubernetes-environment) section in this document for more details on the unpause operation.

1. Check the unpause started time.

   You must note the unpause started time to decide the concrete **period** that you can recover data using the PITR feature.

1. Check the pod status after backup.

   You must check the following four points using the `kubectl get pod` command after you finish the backup operation.
   * The number of Scalar product pods (You must compare this number with the number before the backup).
   * The Scalar product pod names in the `NAME` column (You must compare these pod names with the pod names before the backup).
   * The Scalar product pod status is `Running` in the `STATUS` column.
   * The restart counts of each pod in the `RESTARTS` column (You must compare these restart counts with the restart counts before the backup).

   **If the two values are compared and different, you must re-try the backup operation all over again.** This is because, if some pods are added or restarted, those pods run with a `unpause` state. The `unpause` state pods cause data inconsistency in the backup data.

1. (DynamoDB only) You need to do additional operations to create a backup if you use the PITR feature of DynamoDB since it restores data with another name table by PITR. You should these additional steps after you complete this creating **period** steps. Please refer to the [Restore database guide](./RestoreDatabase.md#amazon-dynamodb) for more details on these steps.

## Multiple databases backup

If you use more than two databases under the Scalar products using [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md), you must pause all Scalar products at the same time and create the same **period** for multiple databases.

To keep consistency between multiple databases, you must restore multiple databases to the same point-in-time data using the PITR feature.

## How to use scalar-admin on a Kubernetes environment

### Check the Kubernetes resource name

You must specify the SRV service URL to the `-s (--srv-service-url)` flag. In the Kubernetes environment, the format of the SRV service URL is `_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local`.

If you use Scalar Helm Chart to deploy Scalar products, the `my-svc` and `my-namespace` are variable depending on the environment. You must specify the Headless Service name as `my-svc` and the namespace as `my-namespace`.

* Example
  * ScalarDB Server
    ```console
    _scalardb._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```
  * ScalarDL Ledger
    ```console
    _scalardl-admin._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```
  * ScalarDL Auditor
    ```console
    _scalardl-auditor-admin._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```

The Headless Service name `<helm release name>-headless` is decided based on the helm release name. You can see the helm release name using the `helm list` command.

```console
$ helm list -n ns-scalar
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS                                                       CHART                    APP VERSION
scalardb                ns-scalar       1               2023-02-09 19:31:40.527130674 +0900 JST deployed                                                     scalardb-2.5.0           3.8.0
scalardl-auditor        ns-scalar       1               2023-02-09 19:32:03.008986045 +0900 JST deployed                                                     scalardl-audit-2.5.1     3.7.1
scalardl-ledger         ns-scalar       1               2023-02-09 19:31:53.459548418 +0900 JST deployed                                                     scalardl-4.5.1           3.7.1
```

You can also see the Headless Service name `<helm release name>-headless` directly using the `kubectl get service` command.

```console
$ kubectl get service -n ns-scalar
NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                           AGE
scalardb-envoy                   LoadBalancer   10.99.245.143    <pending>     60051:31110/TCP                   2m2s
scalardb-envoy-metrics           ClusterIP      10.104.56.87     <none>        9001/TCP                          2m2s
scalardb-headless                ClusterIP      None             <none>        60051/TCP                         2m2s
scalardb-metrics                 ClusterIP      10.111.213.194   <none>        8080/TCP                          2m2s
scalardl-auditor-envoy           LoadBalancer   10.111.141.43    <pending>     40051:31553/TCP,40052:31171/TCP   99s
scalardl-auditor-envoy-metrics   ClusterIP      10.104.245.188   <none>        9001/TCP                          99s
scalardl-auditor-headless        ClusterIP      None             <none>        40051/TCP,40053/TCP,40052/TCP     99s
scalardl-auditor-metrics         ClusterIP      10.105.119.158   <none>        8080/TCP                          99s
scalardl-ledger-envoy            LoadBalancer   10.96.239.167    <pending>     50051:32714/TCP,50052:30857/TCP   109s
scalardl-ledger-envoy-metrics    ClusterIP      10.97.204.18     <none>        9001/TCP                          109s
scalardl-ledger-headless         ClusterIP      None             <none>        50051/TCP,50053/TCP,50052/TCP     109s
scalardl-ledger-metrics          ClusterIP      10.104.216.189   <none>        8080/TCP                          109s
```

### Pause

You can send the pause request to Scalar product pods on the Kubernetes environment.

* Example
  * ScalarDB Server
    ```console
    kubectl run scalar-admin-pause --image=ghcr.io/scalar-labs/scalar-admin:<tag> --restart=Never -it -- -c pause -s _scalardb._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```
  * ScalarDL Ledger
    ```console
    kubectl run scalar-admin-pause --image=ghcr.io/scalar-labs/scalar-admin:<tag> --restart=Never -it -- -c pause -s _scalardl-admin._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```
  * ScalarDL Auditor
    ```console
    kubectl run scalar-admin-pause --image=ghcr.io/scalar-labs/scalar-admin:<tag> --restart=Never -it -- -c pause -s _scalardl-auditor-admin._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```

### Unpause

You can send the unpause request to Scalar product pods on the Kubernetes environment.

* Example
  * ScalarDB Server
    ```console
    kubectl run scalar-admin-unpause --image=ghcr.io/scalar-labs/scalar-admin:<tag> --restart=Never -it -- -c unpause -s _scalardb._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```
  * ScalarDL Ledger
    ```console
    kubectl run scalar-admin-unpause --image=ghcr.io/scalar-labs/scalar-admin:<tag> --restart=Never -it -- -c unpause -s _scalardl-admin._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```
  * ScalarDL Auditor
    ```console
    kubectl run scalar-admin-unpause --image=ghcr.io/scalar-labs/scalar-admin:<tag> --restart=Never -it -- -c unpause -s _scalardl-auditor-admin._tcp.<helm release name>-headless.<namespace>.svc.cluster.local
    ```

### Check the pause completed time and unpause started time

The scalar-admin pods output the **pause completed time** and **unpause started time** to the stdout. You can also see those times using the `kubectl logs` command.

```console
kubectl logs scalar-admin-pause
```
```console
kubectl logs scalar-admin-unpause
```
