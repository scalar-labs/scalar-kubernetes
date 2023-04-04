# Back up a NoSQL database in a Kubernetes environment

This guide explains how to create a transactionally consistent backup of managed databases that ScalarDB or ScalarDL uses in a Kubernetes environment. Please note that, when using a NoSQL database or multiple databases, you **must** pause ScalarDB or ScalarDL to create a transactionally consistent backup.

For details on how ScalarDB backs up databases, see [A Guide on How to Backup and Restore Databases Used Through ScalarDB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md).

In this guide, we assume that you are using point-in-time recovery (PITR) or its equivalent features. Therefore, we must create a period where there are no ongoing transactions for restoration. You can then restore data to that specific period by using PITR. If you restore data to a time without creating a period where there are no ongoing transactions, the restored data could be transactionally inconsistent, causing ScalarDB or ScalarDL to not work properly with the data.

## Create a period to restore data, and perform a backup

1. Check the following four points by running the `kubectl get pod` command before starting the backup operation:
   * **The number of ScalarDB or ScalarDL pods.** Write down the number of pods so that you can compare that number with the number of pods after performing the backup.
   * **The ScalarDB or ScalarDL pod names in the `NAME` column.** Write down the pod names so that you can compare those names with the pod names after performing the backup.
   * **The ScalarDB or ScalarDL pod status is `Running` in the `STATUS` column.** Confirm that the pods are running before proceeding with the backup. You will need to pause the pods in the next step.
   * **The restart count of each pod in the `RESTARTS` column.** Write down the restart count of each pod so that you can compare the count with the restart counts after performing the backup.
2. Pause the ScalarDB or ScalarDL pods by using `scalar-admin`. For details on how to pause the pods, see the [Details on using `scalar-admin`](./BackupNoSQL.md#details-on-using-scalar-admin) section in this guide.
3. Write down the `pause completed` time. You will need to refer to that time when restoring the data by using the PITR feature.
4. Back up each database by using the backup feature. If you have enabled the automatic backup and PITR features, the managed databases will perform back up automatically. Please note that you should wait for approximately 10 seconds so that you can create a sufficiently long period to avoid a clock skew issue between the client clock and the database clock. This 10-second period is the exact period in which you can restore data by using the PITR feature.
5. Unpause ScalarDB or ScalarDL pods by using `scalar-admin`. For details on how to unpause the pods, see the [Details on using `scalar-admin`](./BackupNoSQL.md#details-on-using-scalar-admin) section in this guide.
6. Check the `unpause started` time. You must check the `unpause started` time to confirm the exact period in which you can restore data by using the PITR feature.
7. Check the pod status after performing the backup. You must check the following four points by using the `kubectl get pod` command after the backup operation is completed.
   * **The number of ScalarDB or ScalarDL pods.** Confirm this number matches the number of pods that you wrote down before performing the backup.
   * **The ScalarDB or ScalarDL pod names in the `NAME` column.** Confirm the names match the pod names that you wrote down before performing the backup.
   * **The ScalarDB or ScalarDL pod status is `Running` in the `STATUS` column.**
   * **The restart count of each pod in the `RESTARTS` column.** Confirm the counts match the restart counts that you wrote down before performing the backup
   
   **If any of the two values are different, you must retry the backup operation from the beginning.** The reason for the different values may be caused by some pods being added or restarted while performing the backup. In such case, those pods will run in the `unpause` state. Pods in the `unpause` state will cause the backup data to be transactionally inconsistent.
8. **(Amazon DynamoDB only)** If you use the PITR feature of DynamoDB, you will need to perform additional steps to create a backup because the feature restores data with another name table by using PITR. For details on the additional steps after creating the exact period in which you can restore the data, please see [Restore databases in a Kubernetes environment](./RestoreDatabase.md#amazon-dynamodb).

## Back up multiple databases

If you have two or more databases that the [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md) feature uses, you must pause all instances of ScalarDB or ScalarDL and create the same period where no ongoing transactions exist in the databases.

To ensure consistency between multiple databases, you must restore the databases to the same point in time by using the PITR feature.

## Details on using `scalar-admin`

### Check the Kubernetes resource name

You must specify the SRV service URL to the `-s (--srv-service-url)` flag. In Kubernetes environments, the format of the SRV service URL is `_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local`.

If you use Scalar Helm Charts to deploy ScalarDB or ScalarDL, the `my-svc` and `my-namespace` may vary depending on your environment. You must specify the headless service name as `my-svc` and the namespace as `my-namespace`.

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

The helm release name decides the headless service name `<helm release name>-headless`. You can see the helm release name by running the `helm list` command.

```console
$ helm list -n ns-scalar
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS                                                       CHART                    APP VERSION
scalardb                ns-scalar       1               2023-02-09 19:31:40.527130674 +0900 JST deployed                                                     scalardb-2.5.0           3.8.0
scalardl-auditor        ns-scalar       1               2023-02-09 19:32:03.008986045 +0900 JST deployed                                                     scalardl-audit-2.5.1     3.7.1
scalardl-ledger         ns-scalar       1               2023-02-09 19:31:53.459548418 +0900 JST deployed                                                     scalardl-4.5.1           3.7.1
```

You can also see the headless service name `<helm release name>-headless` by running the `kubectl get service` command.

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

You can send a pause request to ScalarDB or ScalarDL pods in a Kubernetes environment.

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

You can send an unpause request to ScalarDB or ScalarDL pods in a Kubernetes environment.

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

### Check the `pause completed` time and `unpause started` time

The `scalar-admin` pods output the `pause completed` time and `unpause started` time to stdout. You can also see those times by running the `kubectl logs` command.

```console
kubectl logs scalar-admin-pause
```
```console
kubectl logs scalar-admin-unpause
```
