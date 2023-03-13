# Back up an RDB in a Kubernetes environment

This guide explains how to create a backup of a single relational database (RDB) that ScalarDB or ScalarDL uses in a Kubernetes environment. Please note that this guide assumes that you are using a managed database from a cloud services provider.

If you have two or more RDBs that the [Multi-storage Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/multi-storage-transactions.md) or [Two-phase Commit Transactions](https://github.com/scalar-labs/scalardb/blob/master/docs/two-phase-commit-transactions.md) feature uses, you must follow the instructions in [Back up a NoSQL database in a Kubernetes environment](./BackupNoSQL.md) instead.

## Perform a backup

To perform backups, you should enable the automated backup feature available in the managed databases. By enabling this feature, you do not need to perform any additional backup operations. For details on the backup configurations in each managed database, see the following guides:

* [Set up a database for ScalarDB/ScalarDL deployment on AWS](./SetupDatabaseForAWS.md)
* [Set up a database for ScalarDB/ScalarDL deployment on Azure](./SetupDatabaseForAzure.md)

Because the managed RDB keeps backup data consistent from a transactions perspective, you can restore backup data to any point in time by using the point-in-time recovery (PITR) feature in the managed RDB.
