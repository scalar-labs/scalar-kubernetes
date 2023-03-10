# Back up and restore ScalarDB or ScalarDL data in a Kubernetes environment

This guide explains how to backup and restore ScalarDB or ScalarDL data in a Kubernetes environment. Please note that this guide assumes that you are using a managed database from a cloud services provider as the backend database for ScalarDB or ScalarDL. The following is a list of the managed databases that this guide assumes you might be using:

* NoSQL: does not support transactions
   * Amazon DynamoDB
   * Azure Cosmos DB for NoSQL
* Relational database (RDB): supports transactions
   * Amazon RDS
      * MySQL
      * Oracle
      * PostgreSQL
      * SQL Server
   * Amazon Aurora
      * MySQL
      * PostgreSQL
   * Azure Database
      * MySQL
      * PostgreSQL

For details on how to back up and restore databases used with ScalarDB in a transactionally consistent way, see [A Guide on How to Backup and Restore Databases Used Through ScalarDB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md).

## Perform a back up

### Confirm the type of database and number of databases you are using

How you perform backup and restore depends on the type of database (NoSQL or RDB) and the number of databases you are using.

#### NoSQL or multiple databases

If you use a NoSQL database, please refer to the following document for more details on the backup operations.

* [Backup NoSQL database guide](./BackupNoSQL.md)

Also, if you use multiple databases under the Scalar products using [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md), you must do the backup operations according to the above document.

#### Single RDB

If you use a single RDB, please refer to the following document for more details on the backup operations.

* [Backup RDB guide](./BackupRDB.md)

Even if you use RDB, you must follow the [Backup NoSQL database guide](./BackupNoSQL.md) when you use more than two RDBs under the Scalar products using [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md).

## Restore a database

For details on how to restore data from a managed database, please see [Restore databases in a Kubernetes environment](./RestoreDatabase.md).
