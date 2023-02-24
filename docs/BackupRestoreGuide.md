# Backup restore guide for Scalar products

This guide explains how to backup/restore ScalarDB/ScalarDL data on the Kubernetes environment. We assume you use the managed databases provided by cloud services as a backend database of ScalarDB/ScalarDL. Specifically, we assume the following managed databases.

* NoSQL (Not support transactions)
   * Amazon DynamoDB
   * Azure Cosmos DB for NoSQL
* RDB (support transactions)
   * Amazon RDS (MySQL, PostgreSQL, Oracle, and SQL Server)
   * Amazon Aurora (MySQL and PostgreSQL)
   * Azure Database (MySQL and PostgreSQL)

Please refer to the following document for more details on the ScalarDB's backup/restore in a transactionally-consistent way.

* [A Guide on How to Backup and Restore Databases Used Through ScalarDB](https://github.com/scalar-labs/scalardb/blob/master/docs/backup-restore.md)

## Backup

### What database do you use? How many databases do you use?

What operation you need depends on the kind of database (NoSQL or RDB) and the number of databases.

#### Using NoSQL or multiple databases

If you use a NoSQL database, please refer to the following document for more details on the backup operations.

* [Backup NoSQL database guide](./BackupNoSQL.md)

Also, if you use multiple databases under the Scalar products using [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md), you must do the backup operations according to the above document.

#### Using single RDB

If you use a single RDB, please refer to the following document for more details on the backup operations.

* [Backup RDB guide](./BackupRDB.md)

Even if you use RDB, you must follow the [Backup NoSQL database guide](./BackupNoSQL.md) when you use more than two RDBs under the Scalar products using [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md).

## Restore

Please refer to the following document for the details on how to restore data in each managed database.

* [Restore database guide](./RestoreDatabase.md)
