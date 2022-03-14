# Set up a database for Scalar DB/Scalar DL deployment in AKS

This guide explains how to set up a database for Scalar DB/Scalar DL deployment in AKS.

## Cosmos DB

In this section, you will create a Cosmos DB account.

### Requirements

* You must create a Cosmos DB account with `Core(SQL)` API.
* You must change Cosmos DB `Default consistency` to `Strong`.
* You must use Capacity mode as `Provisioned throughput`.

### Recommendations

* You should configure the backup policy as `Continuous` for Point-in-time-restore (PITR).
* You should configure the service endpoint based on the [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-configure-vnet-service-endpoint) to restrict access to Cosmos DB for production.

### Steps

* Create an Azure Cosmos DB account based on the [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account) with the above requirements.

### Scale Performance

Cosmos DB performance can be adjusted using the following parameters.

#### Request Units (RU)

Request unit is a performance currency abstracting the system resources such as CPU, IOPS, and memory that are required to perform the database operations supported by Azure Cosmos DB.
You can scale the throughput of Cosmos DB by specifying `cosmosBaseResourceUnit` (which applies to all the tables) in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml).
Scalar schema tool abstracts Request Unit of Cosmos DB with RU. So please set the appropriate value.

#### Autoscale

Autoscale provisioned throughput in Azure Cosmos DB allows you to scale the throughput (RU/s) of your database or container automatically and instantly.
The throughput is scaled based on the usage, without impacting the availability, latency, throughput, or performance of the workload.
By default, the scalardl schema tool enables autoscale of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload.

### Monitor Cosmos DB

By default, monitoring is enabled on Cosmos DB.

More information can be found in [Monitor Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db) documentation.

## Azure Database for MySQL

Azure Database for MySQL is a fully managed MySQL database provided by Azure. You can create a MySQL database by selecting a database instance and storage according to your configurations. The IOPS is calculated based on the compute instance and storage you choose.

You can choose Flexible or Single server deployment for Azure Database for MySQL, follow the [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/select-right-deployment-type) to learn more.
In this section, you will create an Azure Database for MySQL.

### Steps

For creating an Azure Database for MySQL, 
* For Single Server deployment, follow this [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-portal).
* For creating a flexible server deployment, follow this [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/quickstart-create-server-portal).

### Scale Performance

**Scaling resources**

Resources can be scaled based on the deployment you select.
* Follow the [Azure official guide](https://docs.microsoft.com/en-gb/azure/mysql/concepts-pricing-tiers#scale-resources) for scaling single server deployment resources.
* Follow the [Azure official guide](https://docs.microsoft.com/en-gb/azure/mysql/flexible-server/concepts-compute-storage#scale-resources) for scaling flexible server deployment resources.

**Scaling storage**

The `storage auto grow` feature automatically increases storage when it reaches a threshold without impacting the workload.

### Monitor Azure Database for MySQL

By default, Azure Database for MySQL servers has monitoring enabled.

For more information, check the [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/concepts-monitoring).
