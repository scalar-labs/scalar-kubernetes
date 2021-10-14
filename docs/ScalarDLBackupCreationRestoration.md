# Scalar DL Backup Creation and Restoration

Scalar DL backup should be created after the Scalar DL server is paused otherwise there is a chance for inconsistency. 
This guide shows you how to create and restore Scalar DL data backup without any data inconsistency.

## Prerequisites

* Read the Guide on How to [Back up and Restore Databases Integrated with Scalar DB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md)
* Scalar DL must be deployed in the Kubernetes cluster
* Cosmos DB account must be created with the backup policy `continuous` if you are using Cosmos DB.
* You must synchronize time on the ledger and auditor servers if you are using the audit service.

## Backup Creation

This section shows how to create a transactionally-consistent backup for Scalar DL.

### Requirements

* You must wait at least 10 sec after pausing to create a backup.
* You must identify a unique `Point In Time Restoration` for the ledger and auditor if you are using both the ledger and audit services. 

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

Use the following command to unpause the Scalar DL service after at least 10 seconds

```console
kubectl exec -i -t scalaradminutils -- ./bin/scalar-admin -c unpause -s <SRV_Service_URL>
```

## Restore

This section shows how to restore transactionally-consistent backup for Scalar DL.

### Requirements

* You must use a middle value of the paused time as restore point.
* You must restore Scalar Ledger and Auditor tables with the same restore point if you are using the ledger and audit services.

### Cosmos DB

* Follow the [Restore an Azure Cosmos DB account that uses continuous backup mode](https://docs.microsoft.com/en-us/azure/cosmos-db/restore-account-continuous-backup#restore-account-portal) document to restore.
* Change the default consistency to STRONG after restoring the data.

### DynamoDB

1. Restore tables by specifying the time
    
    * On the Amazon DynamoDB console, you can restore the tables one by one. 
    
        A. Restore the PITR (Point In Time Restore) backup of scalar/auditor tables on the basis of [AWS official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.Tutorial.html#restoretabletopointintime_console).
        
        B. Create the backup of previously restored tables (A) using the [AWS official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Backup.Tutorial.html#backup_console).
        
        C. Delete all scalar/auditor tables except the previously restored tables (A).
        
        D. Restore the previously created backup (B) using the actual scalar/auditor table name (previously deleted tables (C)) on the basis of [AWS official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Restore.Tutorial.html#restoretable_console).
    
    * On the AWS Command Line Interface, You can restore all tables using following shell script.
        * Configure AWS CLI with the region of DynamoDB.
        ```console
        aws configure
        ```
        * Download the [Point In Time Restore](./script/dynamodb_pitr.sh) script.
        * Execute the script with restore point as UNIX time (UTC) and all table names
            * `time` must be without millisecond
            * All tables except `scalardb.metadata` must be passed to the restore script
        ```console
        #Example
        #For ledger restoration
        ./restore_dynamo.sh --time 1613960773 coordinator.state scalar.asset scalar.asset_metadata scalar.certificate scalar.contract scalar.contract_class scalar.function
        
        #For auditor restoration
        ./restore_dynamo.sh --time 1613960773 auditor.asset auditor.contract auditor.contract_class auditor.certificate auditor.request_proof auditor.asset_lock 
        ```
     
2. Insert the new metadata and enable continuous backup and auto-scaling with the schema tool
    * You must enable continuous backup and auto-scaling since they are disabled after restoring data.
    * You must execute the same command as creating a schema. The schema tool doesn't remake the existing tables.
         ```console
         #Using scalar schema standalone tool
         java -jar scalar-schema-standalone-<version>.jar --dynamo --region <REGION> -u <DYNAMODB_USER> -f [ledger-schema.json/auditor-schema.json]
         
         OR
         
         #Using helm charts
         helm upgrade --install load-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml [--set schemaLoading.schemaType=auditor]
         ```