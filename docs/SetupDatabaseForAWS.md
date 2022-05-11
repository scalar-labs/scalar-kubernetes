# Set up a database for Scalar DB/Scalar DL deployment on AWS

This guide explains how to set up a database for Scalar DB/Scalar DL deployment on AWS.

## DynamoDB

By default, Amazon DynamoDB is available for all AWS users. The Scalar DL/Scalar DB schema loader will set the required configurations while creating the schema. You do not need to set up anything manually.

### Steps

* (Optional)  Configure advanced monitoring services with [Azure official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/monitoring-automated-manual.html), monitoring is enabled in DynamoDB by default.


## AWS RDS for MySQL, PostgreSQL, Oracle, SQL Server

In this section, you will create an AWS RDS for MySQL/PostgreSQL/Oracle/SQL Server.

### Steps

* Follow this [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html) to create a database instance.
* (Optional) To increase or autoscale storage, follow this [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html). 
* (Optional) Configure advanced monitoring services with [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html), monitoring is enabled by default.

Note:-

* You can scale up or scale down the instance and memory used. In addition, AWS also has the option to provide additional storage.
* You can autoscale IOPS up to a threshold you set if you select `Provisioned IOPS SSD` as the `storage type`.


