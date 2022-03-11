# Set up a database for Scalar DB/Scalar DL deployment on EKS

This guide explains how to set up a database for Scalar DB/Scalar DL deployment on EKS.

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

## AWS RDS for MySQL, PostgreSQL, Oracle, SQL Server

Amazon Relational Database Service(RDS) is a cloud-based distributed relational database service provided by Amazon Web Services.
Scalar DL and Scalar DB support the following AWS RDS databases.
* AWS RDS for MySQL
* AWS RDS for PostgreSQL
* AWS RDS for Oracle
* AWS RDS for SQL Server

In this section, you will create an AWS RDS for MySQL/PostgreSQL/Oracle/SQL Server.

### Recommendations

* You should select either [General Purpose SSD storage](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#Concepts.Storage.GeneralSSD) or [Provisioned IOPS SSD storage](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS) for storage according to your requirements.
    * You should select the storage type and amount of storage to ensure that adequate IOPS is available as per your requirements.
* You should check the [AWS guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html#CHAP_BestPractices.DiskPerformance) to learn more about AWS RDS best practices.

### Steps

Follow this [AWS guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html) to create a database instance.

### Scale Performance
You can scale up or scale down the instance and memory used. In addition, AWS also has the option to provide additional storage.
It is also possible to add read replicas to improve read-heavy database workloads.

#### Autoscaling

AWS RDS provides the option to autoscale storage. Read more about it [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html). It is also possible to autoscale IOPS to a threshold of your choice if you select `Provisioned IOPS SSD` as the `storage type`.

### Monitor AWS RDS

By default, AWS RDS Databases have monitoring enabled.

Follow this [AWS guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html) to learn more about monitoring.

## Amazon Aurora

Amazon Aurora is a MySQL and PostgreSQL-compatible relational database built for the cloud.
In this section, you will create an Amazon Aurora Database for MySQL/PostgreSQL.

### Recommendations

* You should check the best practices for Amazon Aurora from the [AWS guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.BestPractices.html).

### Steps

To create an Amazon Aurora cluster, follow the [AWS guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html).

### Scale Performance

There are various options to manage performance and scaling for Aurora DB clusters and DB instances.
Read more about this [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Performance.html).

#### Autoscaling

Autoscaling can be enabled in Amazon Aurora if you have created the Amazon Aurora cluster with one primary instance and at least one Aurora Replica. Read more about it [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Integrating.AutoScaling.html).

### Monitor Amazon Aurora

By default, Amazon Aurora Databases have monitoring enabled.

Refer the [AWS guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_Monitoring.html) for more information.
