# Scalar DL Backup Creation and Restoration

Scalar DL backup should be created after the Scalar DL server is paused otherwise there is a chance for inconsistency. 
This guide shows you how to create and restore Scalar DL data backup without any data inconsistency.

## Prerequisites

* Read the Guide on How to [Back up and Restore Databases Integrated with Scalar DB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md)
* Scalar DL must be deployed in the Kubernetes cluster
* Cosmos DB account must be created with the backup policy `continuous` if you are using Cosmos DB.

## Backup Creation

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

* Cosmos DB and DynamoDB will create backup automatically.

### Unpause

Use the following command to unpause the Scalar DL service after the backup creation

```console
kubectl exec -i -t scalaradminutils -- ./bin/scalar-admin -c unpause -s <SRV_Service_URL>
```

## Restore

You can use the time of paused second as a restoration point for PITR.

### Cosmos DB

Follow the [Restore an Azure Cosmos DB account that uses continuous backup mode](https://docs.microsoft.com/en-us/azure/cosmos-db/restore-account-continuous-backup#restore-account-portal) document

### DynamoDB

1. Restore tables by specifying the time
    * On the web console, [Restoring a table one by one from a backup](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Restore.Tutorial.html#restoretable_console).
    * With restore_dynamo.sh script, Following script will help to restore all tables.
        * The time should be specified in UNIX time (UTC)
        * This script adds a prefix ${time}- to each name of all restored table 
   
       ```shell script
        #!/bin/sh -e
        export AWS_PAGER=""
        
        tables=()
        while [ $# -gt 0 ]; do
            case ${1} in
                --time)
                    time="${2}"
                    shift 2
                    ;;
                *)
                  tables+=("${1}")
                  shift 1
                  ;;
            esac
        done
        
        for table in "${tables[@]}"
        do
          aws dynamodb restore-table-to-point-in-time \
          --source-table-name ${table} \
          --target-table-name ${time}-${table} \
          --no-use-latest-restorable-time \
          --restore-date-time ${time}
        
          while true
          do
            status=$(aws dynamodb describe-table --table-name ${time}-${table} | jq '.Table.TableStatus')
            if [ "${status}" = "\"ACTIVE\"" ]; then
              break
            fi
            sleep 60
          done
        done
        ```
        * Should restore all indexes
        * How to execute script:
        ```console
        #Example
        ./restore_dynamo.sh --time 1613960773 coordinator.state scalar.asset scalar.asset_metadata scalar.certificate scalar.contract scalar.contract_class scalar.function
        ```
2. Insert the new metadata and enable continuous backup and auto-scaling with the schema tool
    * You must make the new metadata table and insert metadata since the table names are different from those of the source tables
    * You must enable continuous backup and auto-scaling since they are disabled after restoring data
    * You can just execute the same command as creating a schema. The schema tool doesn't remake the existing tables.
     ```console
     java -jar scalar-schema-standalone-<version>.jar --dynamo --region <REGION> -u <DYNAMODB_USER> -p <DYNAMODB_PASS>
     ```