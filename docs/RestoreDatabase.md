# Restore database guide

This guide explains how to restore ScalarDB/ScalarDL data on a Kubernetes environment. We assume you use the managed databases provided by cloud services as a backend database of ScalarDB/ScalarDL.

## Restore operations

1. Scale in the Scalar product pods to **0** for stopping requests from Scalar products to backend databases.

   You can scale in the Scalar product pods to 0 using the `--set *.replicaCount=0` flag of the helm command.

   * ScalarDB Server
     ```console
     helm upgrade <release name> scalar-labs/scalardb -n <namespace> -f /path/to/<your custom values file for ScalarDB Server> --set scalardb.replicaCount=0
     ```
   * ScalarDL Ledger
     ```console
     helm upgrade <release name> scalar-labs/scalardl -n <namespace> -f /path/to/<your custom values file for ScalarDL Ledger> --set ledger.replicaCount=0
     ```
   * ScalarDL Auditor
     ```console
     helm upgrade <release name> scalar-labs/scalardl-audit -n <namespace> -f /path/to/<your custom values file for ScalarDL Auditor> --set auditor.replicaCount=0
     ```

1. Restore databases.

   Restore the database data using the PITR feature. Please refer to the [Restore databases](./RestoreDatabase.md#restore-databases) section in this document.

   If you use NoSQL or multiple databases, it is recommended to specify the mid-time of the **period** that you created in the document [Backup NoSQL database guide](./BackupNoSQL.md).

1. Update database.properties/ledger.properties/auditor.properties based on the newly restored database.

   The PITR feature restores databases as another instance. So, you must update endpoint information in the custom values file of Scalar products to access the newly restored databases.

   Please refer to the following document for more details on how to configure the custom values file.

   * [Configure a custom values file for Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-file.md)

   Note that if you use Amazon DynamoDB, it restores data with another table name instead of another instance. In other words, the endpoint is not changed by restoring data. Instead, you need to restore and rename tables in Amazon DynamoDB. Please refer to the [Amazon DynamoDB](./RestoreDatabase.md#amazon-dynamodb) section in this document.

1. Scale out the Scalar product pods to more than 1 to start accepting requests from clients.

   You can scale out the Scalar product pods using the `--set *.replicaCount=N` flag of the helm command.

   * ScalarDB Server
     ```console
     helm upgrade <release name> scalar-labs/scalardb -n <namespace> -f /path/to/<your custom values file for ScalarDB Server> --set scalardb.replicaCount=3
     ```
   * ScalarDL Ledger
     ```console
     helm upgrade <release name> scalar-labs/scalardl -n <namespace> -f /path/to/<your custom values file for ScalarDL Ledger> --set ledger.replicaCount=3
     ```
   * ScalarDL Auditor
     ```console
     helm upgrade <release name> scalar-labs/scalardl-audit -n <namespace> -f /path/to/<your custom values file for ScalarDL Auditor> --set auditor.replicaCount=3
     ```

## Restore databases

### Amazon DynamoDB

Amazon DynamoDB restores data with another name table by PITR. So, you must additional operations to restore data with the same table name.

#### Steps

1. Create a backup
   1. Select the mid-time of paused duration as the restore point
   1. Restore with PITR of table A to another table B
   1. Take a backup of the restored table B (assume the backup is named backup B)
   1. Remove table B 

   Please refer to the following official documents for more details on how to restore DynamoDB tables with PITR and how to take a backup of DynamoDB tables manually.

   * [Restoring a DynamoDB table to a point in time](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.Tutorial.html)
   * [Backing up a DynamoDB table](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Backup.Tutorial.html)

   You can do this **Create a backup** step as a part of backup operations in the [Backup NoSQL database guide](./BackupNoSQL.md#backup-operations-create-the-period-for-restoring).

1. Restore from the backup
   1. Remove table A
   1. Create a table named A with backup B

1. Update the table configuration if you need.

   As described in the following document, some configurations (e.g., auto scaling policies) are not set after restoring. So, you need to set those configurations manually if you need.

   * [Backing up and restoring DynamoDB tables with DynamoDB: How it works](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/CreateBackup.html)

   Especially, if you use ScalarDB Schema Loader or ScalarDL Schema Loader to create tables, it enables auto scaling by default. So, you must set auto scaling to the restored tables manually. Please refer to the following official document for more details on how to set auto scaling.

   * [Enabling DynamoDB auto scaling on existing tables](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/AutoScaling.Console.html#AutoScaling.Console.ExistingTable)

   Also, after restoring, the point-in-time recovery is disabled and the Read/Write Capacity is reset to the default value. You must set these configurations if you need. Please check some configurations of restored tables according to the following document.

   * [Set up a database for ScalarDB/ScalarDL deployment on AWS (Amazon DynamoDB)](./SetupDatabaseForAWS.md#amazon-dynamodb)

### Azure Cosmos DB for NoSQL

Note that Azure Cosmos DB restores data with another account by PITR. So, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the account.

   Please refer to the following official document for more details on how to restore the Azure Cosmos DB account with PITR.

   * [Restore an Azure Cosmos DB account that uses continuous backup mode](https://learn.microsoft.com/en-us/azure/cosmos-db/restore-account-continuous-backup)

1. Configure a **default consistency level** to **STRONG**.

   The restored account has a default value of **default consistency level**. So, you must configure the **default consistency level** to **STRONG** according to the official document [Configure the default consistency level](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/how-to-manage-consistency#configure-the-default-consistency-level).

1. Update database.properties for Schema Loader based on the newly restored account.

   ScalarDB implements the Cosmos DB adapter by using its stored procedures, which are installed when creating schemas with ScalarDB/ScalarDL Schema Loader. However, the PITR feature of Cosmos DB doesn't restore stored procedures. So, you need to re-install the required stored procedures for all tables after restoration. You can do it using ScalarDB/ScalarDL Schema Loader with the `--repair-all` option.

   For ScalarDB tables, please refer to the following document for more details on how to configure database.properties for ScalarDB Schema Loader.

   * [Getting Started with ScalarDB on Cosmos DB for NoSQL](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb-on-cosmosdb.md)

   For ScalarDL tables, please refer to the following document for more details on how to configure the custom values file for ScalarDL Schema Loader.

   * [Configure a custom values file for ScalarDL Schema Loader](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-scalardl-schema-loader.md)

1. Repair tables.

   You can recreate stored procedures using the `--repair-all` flag of ScalarDB/ScalarDL Schema Loader as follows.

   * ScalarDB tables
     ```console
     java -jar scalardb-schema-loader-<version>.jar --config /path/to/<your database.properties> -f /path/to/<your schema.json file> [--coordinator] --repair-all 
     ```
   * ScalarDL Ledger tables
     ```console
     helm install repair-schema-ledger scalar-labs/schema-loading -n <namespace> -f /path/to/<your custom values file for ScalarDL Schema Loader for Ledger> --set "schemaLoading.commandArgs={--repair-all}"
     ```
   * ScalarDL Auditor tables
     ```console
     helm install repair-schema-auditor scalar-labs/schema-loading -n <namespace> -f /path/to/<your custom values file for ScalarDL Schema Loader for Auditor> --set "schemaLoading.commandArgs={--repair-all}"
     ```

   Please refer to the [Repair tables](https://github.com/scalar-labs/scalardb/blob/master/docs/schema-loader.md#repair-tables) for more details on ScalarDB Schema Loader.

1. Update the table configuration if you need.

   Please check some configurations of the restored account according to the following document.

   * [Set up a database for ScalarDB/ScalarDL deployment on Azure (Azure Cosmos DB for NoSQL)](./SetupDatabaseForAzure.md#azure-cosmos-db-for-nosql)

### Amazon RDS

Note that Amazon RDS restores data with another database instance by PITR. So, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the database instance.

   Please refer to the following official documents for more details on how to restore the Amazon RDS instance with PITR.

   * [Restoring a DB instance to a specified time](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html)
   * [Restoring a Multi-AZ DB cluster to a specified time](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.MultiAZDBCluster.html)

1. Update the table configuration if you need.

   Please check some configurations of the restored database instance according to the following document.

   * [Set up a database for ScalarDB/ScalarDL deployment on AWS (Amazon RDS for MySQL, PostgreSQL, Oracle, and SQL Server)](./SetupDatabaseForAWS.md#amazon-rds-for-mysql-postgresql-oracle-and-sql-server)

### Amazon Aurora

Note that Amazon Aurora restores data with another database cluster by PITR. So, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the database cluster.

   Please refer to the following official document for more details on how to restore the Amazon Aurora cluster with PITR.

   * [Restoring a DB cluster to a specified time](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-pitr.html)

1. Add a replica (reader) to make the database cluster a Multi-AZ cluster if you need.

   The PITR feature of Amazon Aurora cannot restore the database cluster with Multi-AZ configuration. If you want to restore the database cluster as a Multi-AZ cluster, you must add a reader after restoring the database cluster. Please refer to the following official document for more details on how to add a reader.

   * [Adding Aurora Replicas to a DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-replicas-adding.html)

1. Update the table configuration if you need.

   Please check some configurations of the restored database cluster according to the following document.

   * [Set up a database for ScalarDB/ScalarDL deployment on AWS (Amazon Aurora MySQL and Amazon Aurora PostgreSQL)](./SetupDatabaseForAWS.md#amazon-aurora-mysql-and-amazon-aurora-postgresql)

### Azure Database for MySQL/PostgreSQL

Note that Azure Database for MySQL/PostgreSQL restores data with another server by PITR. So, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the database server.

   Please refer to the following official document for more details on how to restore the Azure Database for MySQL/PostgreSQL server with PITR.

   * [Point-in-time restore of a Azure Database for MySQL Flexible Server using Azure portal](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-restore-server-portal)
   * [Backup and restore in Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-backup-restore)

1. Update the table configuration if you need.

   Please check some configurations of the restored database server according to the following document.

   * [Set up a database for ScalarDB/ScalarDL deployment on Azure (Azure Database for MySQL)](./SetupDatabaseForAzure.md#azure-database-for-mysql)
   * [Set up a database for ScalarDB/ScalarDL deployment on Azure (Azure Database for PostgreSQL)](./SetupDatabaseForAzure.md#azure-database-for-postgresql)
