# Set up a database

This guide explains how to set up a database for Scalar DL.

## Cosmos DB

In this section, you will set up a Cosmos DB for Scalar DL.

### Requirements

* You must create a Cosmos DB account with `Core(SQL)` API.
* You must change Cosmos DB `Default consistency` to `Strong`.
* You must use Capacity mode as `Provisioned throughput`.

### Recommendations

* You should configure the backup policy as `Continuous` for Point-in-time-restore (PITR).
* You should configure service endpoint on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-configure-vnet-service-endpoint) to restrict access to Cosmos DB for production.

### Steps

* Create an Azure Cosmos DB account on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account) with the above requirements.

### Scale Performance

Cosmos DB performance can be adjusted using the following parameters.

#### Request Units (RU)

Request unit is a performance currency abstracting the system resources such as CPU, IOPS, and memory that are required to perform the database operations supported by Azure Cosmos DB.
You can scale the throughput of Cosmos DB by specifying `cosmosBaseResourceUnit` (which applies to all the tables) in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml).
Scalar schema tool abstracts Request Unit of Cosmos DB with RU. So please set appropriate value.

#### Autoscale

Autoscale provisioned throughput in Azure Cosmos DB allows you to scale the throughput (RU/s) of your database or container automatically and instantly.
The throughput is scaled based on the usage, without impacting the availability, latency, throughput, or performance of the workload.
By default, the scalardl schema tool enables autoscale of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload.

### Monitor Cosmos DB

By default, monitoring is enabled on Cosmos DB.

More information can be found in [Monitor Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db) documentation.

## DynamoDB

By default, Amazon DynamoDB is available for all AWS users. You do not need to configure anything manually.
Scalar schema tool [helm charts](https://github.com/scalar-labs/helm-charts/tree/main/charts/schema-loading) will help you to configure DynamoDB.

### Scale Performance

DynamoDB performance can be adjusted using the following parameters

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

By default, monitoring is enabled on DynamoDB

More information can be found in [DynamoDB Metrics and Dimensions documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/metrics-dimensions.html).
