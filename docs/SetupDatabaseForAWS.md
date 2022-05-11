# Set up a database for Scalar DB/Scalar DL deployment on AWS

This guide explains how to set up a database for Scalar DB/Scalar DL deployment on AWS.

## DynamoDB

Amazon DynamoDB is available for all AWS users. You do not need to set up anything manually.

### Optional steps

* Configure advanced monitoring services with the [Azure official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/monitoring-automated-manual.html), monitoring is enabled in DynamoDB by default.
* You can change the `Read/Write Capacity` of DynamoDB tables based on your requirements.

Note:-

* Scalar DB/DL schema loader will configure the same Read/Write Capacity for all tables.

## AWS RDS for MySQL, PostgreSQL, Oracle, SQL Server

In this section, you will create an AWS RDS for MySQL/PostgreSQL/Oracle/SQL Server.

### Steps

* Follow this [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html) to create an AWS RDS MySQL/PostgreSQL/Oracle/SQL Server database instance.
* (Optional) Configure advanced monitoring services with the [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html), monitoring is enabled by default on AWS RDS database instances.

Note:-
* Baseline I/O performance for General Purpose SSD storage is 3 IOPS/GB, choose adequate storage to match your performance requirements.
* If you choose `Provisioned IOPS SSD` as the `storage type`, it will scale the IOPS up to a selected limit.


