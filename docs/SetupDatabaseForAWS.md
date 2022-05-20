# Set up a database for Scalar DB/Scalar DL deployment on AWS

This guide explains how to set up a database for Scalar DB/Scalar DL deployment on AWS.

## DynamoDB

Amazon DynamoDB is available for use in AWS by default. You do not need to set up anything manually to use it.

### Optional steps

* Configure advanced monitoring services with the [Azure official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/monitoring-automated-manual.html), monitoring is enabled in DynamoDB by default.
* You should change the `Read/Write Capacity` of DynamoDB tables based on your requirements.

Note:-

* Scalar DB/DL schema loader will configure the same Read/Write Capacity for all tables.

## AWS RDS for MySQL, PostgreSQL, Oracle and SQL Server

### Steps

* Follow this [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html) to create an AWS RDS MySQL/PostgreSQL/Oracle/SQL Server database instance.
* (Optional) Configure advanced monitoring services with the [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html), monitoring is enabled by default on AWS RDS database instances.


## Amazon Aurora for MySQL/PostgreSQL

### Steps

* Follow this [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html) to create an Amazon Aurora cluster for MySQL/PostgreSQL.
* (Optional) Follow this [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Performance.html) to manage performance and scaling for Aurora DB clusters and DB instances.
* (Optional) Configure `Enhanced Monitoring` for Amazon Aurora from the [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_Monitoring.OS.Enabling.html), monitoring is enabled on the Amazon Aurora cluster by default.

Note:-

* Autoscaling can be enabled in Amazon Aurora if you have created the Amazon Aurora cluster with one primary instance and at least one Aurora Replica. Read more about it in [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Integrating.AutoScaling.html).