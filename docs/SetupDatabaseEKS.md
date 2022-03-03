# Set up a database for Scalar DL/Scalar DB deployment on EKS

This guide explains how to set up a database for Scalar DL/Scalar DB deployment on EKS.

## DynamoDB

By default, Amazon DynamoDB is available for all AWS users. You do not need to configure anything manually.
Scalar schema tool [helm charts](https://github.com/scalar-labs/helm-charts/tree/main/charts/schema-loading) will help you to configure DynamoDB.

### Scale Performance

DynamoDB performance can be adjusted using the following parameters.

#### Request Units (RU)

A read capacity unit represents one strongly consistent read per second, or two eventually consistent reads per second, for an item up to 4 KB in size.
You can scale the throughput of DynamoDB by specifying `dynamoBaseResourceUnit` (which applies to all the tables) in the `schema-loading-custom-values.yaml` file.
Scalar schema tool abstracts Capacity Unit of DynamoDB with RU.

#### Autoscale

Amazon DynamoDB auto scaling uses the AWS Application Auto Scaling service to dynamically adjust provisioned throughput capacity on your behalf, in response to actual traffic patterns.
This enables a table or a global secondary index to increase its provisioned read and write capacity to handle sudden increases in traffic, without throttling.

By default, the `scalardl schema tool` enables auto-scaling of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload.

For example, if you specify RU 10000, the RU of each table is scaled in or out between 1000 and 10000.

WARNING:

* Scalar schema tool sets the same value to both Read and Write Request Units.
* By default, the Read and Write Request Unit is 10.

### Monitor DynamoDB

By default, monitoring is enabled on DynamoDB.

More information can be found in [DynamoDB Metrics and Dimensions documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/metrics-dimensions.html).

## AWS RDS Databases (excluding Aurora)

Amazon Relational Database Service(RDS) is a cloud-based distributed relational database service by Amazon Web Services.
It provides MySQL, PostgreSQL, Oracle, SQL Server, Maria DB databases.
Scalar DL and Scalar DB support the following AWS RDS databases.
* AWS RDS for MySQL
* AWS RDS for PostgreSQL
* AWS RDS for Oracle
* AWS RDS for SQL Server

In this section, you will create an AWS RDS Database(Mysql/PostgreSQL/Oracle/SQL Server).

### Recommendations

* Select SSD for storage.

You can check the [official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html#CHAP_BestPractices.DiskPerformance) to learn more about AWS RDS best practices.

### Steps

You can follow this [official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html) to create a database instance.

### Scale Performance

You can scale up or scale down the instance and memory used. In addition, AWS also has the option to provide additional storage.
You can also add read replicas to improve read-heavy database workloads.

#### Autoscaling

You can autoscale storage in RDS. You can also autoscale IOPS and storage to a threshold of your choice if you select `Provisioned IOPS SSD` as the `storage type`.

### Monitoring AWS RDS

By default, AWS RDS Databases have monitoring enabled.
You can follow the [official guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html) to learn more about monitoring.

## AWS Aurora

Amazon Aurora is a MySQL and PostgreSQL-compatible relational database built for the cloud.
In this section, you will create an AWS Aurora Database(MySQL/PostgreSQL).

### Recommendations

You can check the best practices for AWS Aurora from the [official documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.BestPractices.html).

### Steps

You can create an AWS Aurora cluster based on the [AWS official guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html).

### Scale Performance

There are various options to manage performance and scaling for Aurora DB clusters and DB instances.
You can read more about this [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Performance.html).

#### Autoscaling

Autoscaling can be enabled in AWS Aurora if you have created the AWS Aurora cluster with one primary instance and at least on Aurora Replica. You can read more about it [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Integrating.AutoScaling.html).

### Monitor AWS Aurora

By default, AWS Aurora Databases have monitoring enabled.
You can check the [official documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_Monitoring.html) for more information.

**Note**:-
* Please note that Scalar DL and Scalar DB only support the AWS Aurora 3 version compatible with MySQL 8.