# Scalar DL Backup Creation

This guide shows you how to create transactionally consistent Scalar DL backups on Kubernetes services.

## Prerequisites

* Read the [Guide on How to Back up and Restore Databases Integrated with Scalar DB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md)
* Scalar DL must be deployed in a Kubernetes cluster
* Cosmos DB account must be created with the backup policy `continuous` if you use Cosmos DB.
* You must synchronize the clocks (moderately) between Ledger and Auditor servers by using clock synchronization mechanisms such as NTP if you use Auditor. 

## Backup Creation

This section shows how to create a transactionally-consistent backup for Scalar DL.

### Requirements

* You must wait at least 10 sec (based on clock drift) after pausing to create a backup.
    * You must be able to identify a common restore point between the pausing based on the clock drift of the Ledger and Auditor.
* You must identify a unique `Point In Time Restoration` for the ledger and auditor if you use both the ledger and audit services. 

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

To restore the backup, you can follow [Guide on How to Back up and Restore Databases Integrated with Scalar DB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md)
