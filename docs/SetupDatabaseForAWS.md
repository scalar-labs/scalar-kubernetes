# Set up a database for Scalar DB/Scalar DL deployment on AWS

This guide explains how to set up a database for Scalar DB/Scalar DL deployment on AWS.

## DynamoDB

By default, Amazon DynamoDB is available for all AWS users. You do not need to set up anything manually.

### Steps

* (Optional) Configure advanced monitoring services with [Azure official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/monitoring-automated-manual.html), monitoring is enabled in DynamoDB by default.
* (Optional) You can change the `Read/Write Capacity` of a DynamoDB table according to your requirement.

## AWS RDS for MySQL, PostgreSQL, Oracle, SQL Server

In this section, you will create an AWS RDS for MySQL/PostgreSQL/Oracle/SQL Server.

### Steps

* Follow this [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html) to create an AWS RDS MySQL/PostgreSQL/Oracle/SQL Server database instance.
* (Optional) Configure advanced monitoring services with [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html), monitoring is enabled by default on AWS RDS database instances.

Note:-
* Baseline I/O performance for General Purpose SSD storage is 3 IOPS/GB, choose adequate storage to match your performance requirements.
* You can autoscale IOPS up to a chosen limit if you select `Provisioned IOPS SSD` as the `storage type`.


