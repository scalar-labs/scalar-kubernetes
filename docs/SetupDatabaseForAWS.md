# Set up a database for ScalarDB/ScalarDL deployment on AWS

This guide explains how to set up a database for ScalarDB/ScalarDL deployment on AWS.

## Amazon DynamoDB

### Authentication method

When you use DynamoDB, you must set `REGION`, `ACCESS_KEY_ID`, and `SECRET_ACCESS_KEY` in the ScalarDB/ScalarDL properties file as follows.

```properties
scalar.db.contact_points=<REGION>
scalar.db.username=<ACCESS_KEY_ID>
scalar.db.password=<SECRET_ACCESS_KEY>
scalar.db.storage=dynamo
```

Please refer to the following document for more details on the properties for DynamoDB.

* [Getting Started with ScalarDB on DynamoDB](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb-on-dynamodb.md)

### Required configuration/steps

DynamoDB is available for use in AWS by default. You do not need to set up anything manually to use it.

### Optional configurations/steps

#### Enable point-in-time recovery (Recommended in the production environment)

You can enable PITR as a backup/restore method for DynamoDB. If you use [ScalarDB Schema Loader](https://github.com/scalar-labs/scalardb/blob/master/docs/schema-loader.md) for creating schema, it enables the PITR feature for tables by default. Please refer to the official document for more details.

* [Point-in-time recovery for DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html)

#### Configure monitoring (Recommended in the production environment)

You can configure the monitoring and logging of DynamoDB using its native feature. Please refer to the official document for more details.

* [Monitoring and logging](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/monitoring.html)

#### Use VPC endpoint (Recommended in the production environment)

// Note that We have not yet tested this feature with Scalar products.  
// TODO: We need to test this feature with Scalar products.

* [Using Amazon VPC endpoints to access DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/vpc-endpoints-dynamodb.html)

#### Configure Read/Write Capacity (Optional based on your environment)

You can configure the **Read/Write Capacity** of DynamoDB tables based on your requirements. Please refer to the official document for more details on Read/Write Capacity.

* [Read/write capacity mode](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html)

You can configure Read/Write Capacity using ScalarDB/DL Schema Loader when you create a table. Please refer to the following document for more details on how to configure Read/Write Capacity (RU) using ScalarDB/DL Schema Loader.

* [ScalarDB Schema Loader](https://github.com/scalar-labs/scalardb/blob/master/docs/schema-loader.md)

## Amazon RDS for MySQL, PostgreSQL, Oracle, and SQL Server

### Authentication method

When you use RDS, you must set `JDBC_URL`, `USERNAME`, and `PASSWORD` in the ScalarDB/ScalarDL properties file as follows.

```properties
scalar.db.contact_points=<JDBC_URL>
scalar.db.username=<USERNAME>
scalar.db.password=<PASSWORD>
scalar.db.storage=jdbc
```

Please refer to the following document for more details on the properties for RDS (JDBC databases).

* [Getting Started with ScalarDB on JDBC databases](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb-on-jdbc.md)

### Required configuration/steps

#### Create an RDS database instance

You must create an RDS database instance. Please refer to the official document for more details.

* [Configuring an Amazon RDS DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_RDS_Configuring.html)

### Optional configurations/steps

#### Enable automated backups (Recommended in the production environment)

You can enable automated backups. Please refer to the official document for more details.

* [Working with backups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html)

#### Configure monitoring (Recommended in the production environment)

You can configure the monitoring and logging of RDS using its native feature. Please refer to the official documents for more details.

* [Monitoring metrics in an Amazon RDS instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html)
* [Monitoring events, logs, and streams in an Amazon RDS DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitor_Logs_Events.html)

#### Disable public access (Recommended in the production environment)

Public access is disabled by default. You can access the RDS database instance from the Scalar product pods on your EKS cluster as follows.

* Create the RDS database instance on the same VPC as your EKS cluster.
* Connect the VPC for the RDS and the VPC for the EKS cluster for the Scalar product deployment using [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html). (// TODO: We need to test this feature with Scalar products.)

## Amazon Aurora MySQL and Amazon Aurora PostgreSQL

### Authentication method

When you use Amazon Aurora, you must set `JDBC_URL`, `USERNAME`, and `PASSWORD` in the ScalarDB/ScalarDL properties file as follows.

```properties
scalar.db.contact_points=<JDBC_URL>
scalar.db.username=<USERNAME>
scalar.db.password=<PASSWORD>
scalar.db.storage=jdbc
```

Please refer to the following document for more details on the properties for Amazon Aurora (JDBC databases).

* [Getting Started with ScalarDB on JDBC databases](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb-on-jdbc.md)

### Required configuration/steps

#### Create an Amazon Aurora DB cluster

You must create an Amazon Aurora DB cluster. Please refer to the official document for more details.

* [Configuring your Amazon Aurora DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraSettingUp.html)

### Optional configurations/steps

#### Configure backup configurations (Optional based on your environment)

Amazon Aurora automatically gets a backup by default. You do not need to enable the backup feature manually.

If you want to change some backup configurations like the backup retention period and backup window, you can configure them. Please refer to the official document for more details.

* [Backing up and restoring an Amazon Aurora DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/BackupRestoreAurora.html)

#### Configure monitoring (Recommended in the production environment)

You can configure the monitoring and logging of Amazon Aurora using its native feature. Please refer to the official documents for more details.

* [Monitoring metrics in an Amazon Aurora cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/MonitoringAurora.html)
* [Monitoring events, logs, and streams in an Amazon Aurora DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_Monitor_Logs_Events.html)

#### Disable public access (Recommended in the production environment)

Public access is disabled by default. You can access the Amazon Aurora DB cluster from the Scalar product pods on your EKS cluster as follows.

* Create the Amazon Aurora DB cluster on the same VPC as your EKS cluster.
* Connect the VPC for the Amazon Aurora DB cluster and the VPC for the EKS cluster for the Scalar product deployment using [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html). (// TODO: We need to test this feature with Scalar products.)
