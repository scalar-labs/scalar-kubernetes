# Backup RDB guide

This guide explains how to backup single RDB data with Scalar products on a Kubernetes environment. We assume that you use managed databases provided by cloud service.

Even if you use RDB, you must follow the [Backup NoSQL database guide](./BackupNoSQL.md) when you use more than two RDBs under the Scalar products using [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md).

## Backup operations

Basically, there is no backup operation if you use automated backup features provided by managed databases. All you have to do is enable automated backup features. Please refer to the following document for more details on the backup configurations in each managed database.

* [Set up a database for ScalarDB/ScalarDL deployment on AWS](./SetupDatabaseForAWS.md)
* [Set up a database for ScalarDB/ScalarDL deployment on Azure](./SetupDatabaseForAzure.md)

Since the managed RDB keeps backup data consistent from the perspective of transactions. You can restore backup data to any point-in-time using the PITR features.
