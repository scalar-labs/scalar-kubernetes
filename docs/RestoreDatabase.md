# Restore databases in a Kubernetes environment

This guide explains how to restore databases that ScalarDB or ScalarDL uses in a Kubernetes environment. Please note that this guide assumes that you are using a managed database from a cloud services provider as the backend database for ScalarDB or ScalarDL.

## Procedure to restore databases

1. Scale in ScalarDB or ScalarDL pods to **0** to stop requests to the backend databases. You can scale in the pods to **0** by using the `--set *.replicaCount=0` flag in the helm command.
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
2. Restore the databases by using the point-in-time recovery (PITR) feature. 

   For details on how to restore the databases based on your managed database, please refer to the [Supplemental procedures to restore databases based on managed database](./RestoreDatabase.md#supplemental-procedures-to-restore-databases-based-on-managed-database) section in this guide.

   If you are using NoSQL or multiple databases, you should specify the middle point of the pause duration period that you created when following the backup procedure in [Back up a NoSQL database in a Kubernetes environment](./BackupNoSQL.md).
3. Update **database.properties**, **ledger.properties**, or **auditor.properties** based on the newly restored database. 
   
   Because the PITR feature restores databases as another instance, you must update the endpoint information in the custom values file of ScalarDB or ScalarDL to access the newly restored databases. For details on how to configure the custom values file, see [Configure a custom values file for Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-file.md).

   Please note that, if you are using Amazon DynamoDB, your data will be restored with another table name instead of another instance. In other words, the endpoint will not change after restoring the data. Instead, you will need to restore the data by renaming the tables in Amazon DynamoDB. For details on how to restore data with the same table name, please see the [Amazon DynamoDB](./RestoreDatabase.md#amazon-dynamodb) section in this guide.
4. Scale out the ScalarDB or ScalarDL pods to **1** or more to start accepting requests from clients by using the `--set *.replicaCount=N` flag in the helm command.
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

## Supplemental procedures to restore data based on managed database

### Amazon DynamoDB

When using the PITR feature, Amazon DynamoDB restores data with another table name. Therefore, you must follow additional steps to restore data with the same table name.

#### Steps

1. Create a backup.
   1. Select the middle point of the pause duration period as the restore point.
   2. Use PITR to restore table A to table B.
   3. Perform a backup of the restored table B. Then, confirm the backup is named appropriately for backup B.
   4. Remove table B.

   For details on how to restore DynamoDB tables by using PITR and how to perform a backup of DynamoDB tables manually, see the following official documentation from Amazon:

   * [Restoring a DynamoDB table to a point in time](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.Tutorial.html)
   * [Backing up a DynamoDB table](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Backup.Tutorial.html)

   You can do this **Create a backup** step as a part of backup operations in the [Back up a NoSQL database in a Kubernetes environment](./BackupNoSQL.md#create-a-period-to-restore-data-and-perform-a-backup).

2. Restore from the backup.
   1. Remove table A.
   2. Create a table named A by using backup B.

3. Update the table configuration if necessary, depending on your environment.

   Some configurations, like autoscaling policies, are not set after restoring, so you may need to manually set those configurations depending on your needs. For details, see the official documentation from Amazon at [Backing up and restoring DynamoDB tables with DynamoDB: How it works](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/CreateBackup.html).

   For example, if you are using ScalarDB Schema Loader or ScalarDL Schema Loader to create tables, autoscaling is enabled by default. Therefore, you will need to manually enable autoscaling for the restored tables in DynamoDB. For details on how to enable autoscaling in DynamoDB, see the official documentation from Amazon at [Enabling DynamoDB auto scaling on existing tables](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/AutoScaling.Console.html#AutoScaling.Console.ExistingTable).

   In addition, after restoring the databases, the PITR feature will be disabled and the read/write capacity mode is reset to the default value. If necessary, depending on your environment, you will need to manually set these configurations. For some configurations for restored tables, see [Set up a database for ScalarDB/ScalarDL deployment on AWS (Amazon DynamoDB)](./SetupDatabaseForAWS.md#amazon-dynamodb).

### Azure Cosmos DB for NoSQL

When using the PITR feature, Azure Cosmos DB restores data by using another account. Therefore, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the account. For details on how to restore an Azure Cosmos DB account by using PITR, see [Restore an Azure Cosmos DB account that uses continuous backup mode](https://learn.microsoft.com/en-us/azure/cosmos-db/restore-account-continuous-backup).

2. Change the **default consistency level** for the restored account from the default value to **Strong**. For details on how to change this value, see the official documentation from Microsoft a [Configure the default consistency level](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/how-to-manage-consistency#configure-the-default-consistency-level).

3. Update **database.properties** for ScalarDB Schema Loader or ScalarDL Schema Loader based on the newly restored account.

   ScalarDB implements the Cosmos DB adapter by using its stored procedures, which are installed when creating schemas by using ScalarDB Schema Loader or ScalarDL Schema Loader. However, the PITR feature in Cosmos DB does not restore stored procedures, so you will need to reinstall the required stored procedures for all tables after restoration. You can reinstall the required stored procedures by using the `--repair-all` option in ScalarDB Schema Loader or ScalarDL Schema Loader.
   * **ScalarDB tables:** For details on how to configure **database.properties** for ScalarDB Schema Loader, see [Getting Started with ScalarDB on Cosmos DB for NoSQL](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb-on-cosmosdb.md).

   * **ScalarDL tables:** For details on how to configure the custom values file for ScalarDL Schema Loader, see [Configure a custom values file for ScalarDL Schema Loader](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-scalardl-schema-loader.md).

4. Re-create the stored procedures by using the `--repair-all` flag in ScalarDB Schema Loader or ScalarDL Schema Loader as follows:

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

   For more details on repairing tables in ScalarDB Schema Loader, see [Repair tables](https://github.com/scalar-labs/scalardb/blob/master/docs/schema-loader.md#repair-tables).

5. Update the table configuration if necessary, depending on your environment. For some configurations for restored accounts, see [Set up a database for ScalarDB/ScalarDL deployment on Azure (Azure Cosmos DB for NoSQL)](./SetupDatabaseForAzure.md#azure-cosmos-db-for-nosql).

### Amazon RDS

When using the PITR feature, Amazon RDS restores data by using another database instance. Therefore, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the database instance. For details on how to restore the Amazon RDS instance by using PITR, see the following official documentation from Amazon:
   * [Restoring a DB instance to a specified time](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html)
   * [Restoring a Multi-AZ DB cluster to a specified time](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.MultiAZDBCluster.html)

2. Update the table configuration if necessary, depending on your environment. For some configurations for the restored database instance, see [Set up a database for ScalarDB/ScalarDL deployment on AWS (Amazon RDS for MySQL, PostgreSQL, Oracle, and SQL Server)](./SetupDatabaseForAWS.md#amazon-rds-for-mysql-postgresql-oracle-and-sql-server).

### Amazon Aurora

When using the PITR feature, Amazon Aurora restores data by using another database cluster. Therefore, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the database cluster. For details on how to restore an Amazon Aurora cluster by using PITR. see the official documentation from Amazon at [Restoring a DB cluster to a specified time](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-pitr.html).

2. Add a replica (reader) to make the database cluster a Multi-AZ cluster if necessary, depending on your environment.

   The PITR feature in Amazon Aurora cannot restore a database cluster by using a Multi-AZ configuration. If you want to restore the database cluster as a Multi-AZ cluster, you must add a reader after restoring the database cluster. For details on how to add a reader, see the official documentation from Amazon at [Adding Aurora Replicas to a DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-replicas-adding.html).

3. Update the table configuration if necessary, depending on your environment. For some configurations for the restored database cluster, see [Set up a database for ScalarDB/ScalarDL deployment on AWS (Amazon Aurora MySQL and Amazon Aurora PostgreSQL)](./SetupDatabaseForAWS.md#amazon-aurora-mysql-and-amazon-aurora-postgresql).

### Azure Database for MySQL/PostgreSQL

When using the PITR feature, Azure Database for MySQL/PostgreSQL restores data by using another server. Therefore, you must update the endpoint configuration in the custom values file.

#### Steps

1. Restore the database server. For details on how to restore an Azure Database for MySQL/PostgreSQL server by using PITR, see the following:

   * [Point-in-time restore of a Azure Database for MySQL Flexible Server using Azure portal](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-restore-server-portal)
   * [Backup and restore in Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-backup-restore)

2. Update the table configuration if necessary, depending on your environment. For some configurations for the restored database server, see the following:

   * [Set up a database for ScalarDB/ScalarDL deployment on Azure (Azure Database for MySQL)](./SetupDatabaseForAzure.md#azure-database-for-mysql)
   * [Set up a database for ScalarDB/ScalarDL deployment on Azure (Azure Database for PostgreSQL)](./SetupDatabaseForAzure.md#azure-database-for-postgresql)
