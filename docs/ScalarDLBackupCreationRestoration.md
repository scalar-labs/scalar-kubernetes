# Scalar DL Backup Creation on Kubernetes

This guide shows you how to create transactionally consistent Scalar DL backups on DynamoDB or Cosmos DB deployed on Kubernetes services.

## Prerequisites

* Read the [Scalar DL Backup Creation and Restoration](https://github.com/scalar-labs/scalardl/blob/master/docs/backup-restore.md)
* Scalar DL must be deployed in a Kubernetes cluster
* Cosmos DB account must be created with the backup policy `continuous` if you use Cosmos DB.
* DynamoDB schema must be created with scalardl schema loader (It enables PITR).

## Backup Creation

This section shows how to create a transactionally-consistent backup for Scalar DL.

### Requirements

* You must enable Point In Time Restore in the backend database.
* You must wait at least 10 sec after pausing to create a backup.
* You must identify a unique `Point In Time Restoration` for the Ledger and Auditor if you use both the Ledger and Auditor. 

### Find SRV service URL

This section will help you to find the SRV service URL with the help of [SRV records](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#srv-records).
You can confirm the SRV service URL with the [Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/) guide.

Example: 
```
_scalardl-admin._tcp.my-release-scalardl-ledger-headless.default.svc.cluster.local
```

### Create a simple Pod to execute grpcurl

scalaradminutils.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: scalaradminutils
  namespace: default
spec:
  containers:
  - name: scalaradminutils
    image: ghcr.io/scalar-labs/scalar-admin:1.0.0
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
```

Use that manifest to create a Pod:

```console
kubectl apply -f scalaradminutils.yaml
```

Verify pod status:

```console
kubectl get pods scalaradminutils
```

### Pause

Use the following command to pause the Scalar DL service for few seconds

```console
kubectl exec -i -t scalaradminutils -- ./bin/scalar-admin -c pause -s <SRV_Service_URL>
```
Note:-
* Cosmos DB and DynamoDB will create backup automatically.

### Unpause

Use the following command to unpause the Scalar DL service after finding a common restore point based on the clock drift of Ledger and Auditor

```console
kubectl exec -i -t scalaradminutils -- ./bin/scalar-admin -c unpause -s <SRV_Service_URL>
```

## Restore

To restore the backup, you must follow the [Restore Backup](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md#restore-backup) section.
You must restore Scalar Ledger and Auditor tables with the same restore point if you use Ledger and Auditor.
 