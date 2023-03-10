# Back up an RDB in a Kubernetes environment

This guide explains how to backup single RDB data with Scalar products on a Kubernetes environment. We assume that you use managed databases provided by cloud service.

Even if you use RDB, you must follow the [Backup NoSQL database guide](./BackupNoSQL.md) when you use more than two RDBs under the Scalar products using [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md).

## Perform a backup

To perform backups, you should enable the automated backup feature available in the managed databases. By enabling this feature, you do not need to perform any additional backup operations. For details on the backup configurations in each managed database, see the following guides:

* [Set up a database for ScalarDB/ScalarDL deployment on AWS](./SetupDatabaseForAWS.md)
* [Set up a database for ScalarDB/ScalarDL deployment on Azure](./SetupDatabaseForAzure.md)

Because the managed RDB keeps backup data consistent from a transactions perspective, you can restore backup data to any point in time by using the point-in-time recovery (PITR) feature in the managed RDB.
