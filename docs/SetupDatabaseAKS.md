# Set up a database for Scalar DL/Scalar DB deployments in AKS

This guide explains how to set up a database for Scalar DL/Scalar DB deployments in AKS.

## Cosmos DB

In this section, you will create a Cosmos DB account.

### Requirements

* You must create a Cosmos DB account with `Core(SQL)` API.
* You must change Cosmos DB `Default consistency` to `Strong`.
* You must use Capacity mode as `Provisioned throughput`.

### Recommendations

* You should configure the backup policy as `Continuous` for Point-in-time-restore (PITR).
* You should configure the service endpoint based on [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-configure-vnet-service-endpoint) to restrict access to Cosmos DB for production.

### Steps

* Create an Azure Cosmos DB account based on [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account) with the above requirements.

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
In this section, you will create an Azure Database for MySQL.

### Recommendations

* You should choose Flexible or Single server deployment for Azure Database for MySQL. You can check the [official documentation](https://docs.microsoft.com/en-us/azure/mysql/select-right-deployment-type) to learn more about the differences between Flexible and Single server deployments.
* You should select a deployment that suits your IOPS requirements.
    * For Single server deployments, IOPS is defined on the amount of storage provisioned(3 IOPS/GB).
    * For Flexible server deployments, additional IOPS can be provisioned and the maximum threshold will be defined by the storage and the database instance chosen.

### Steps

You can follow [official documentation](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-portal) to create an Azure Database for MySQL server for Single server deployment.
For creating a flexible server deployment for Azure Database for MySQL, you can follow this [official guide](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/quickstart-create-server-portal).

### Scale Performance

**Scaling storage**:- You can enable the `storage auto grow` feature to automatically increase storage when it reaches a threshold without impacting the workload.

You can scale resources based on the deployment you choose. For Single server deployment, you can refer to the [official documentation](https://docs.microsoft.com/en-gb/azure/mysql/concepts-pricing-tiers#scale-resources) for scaling resources.
For Flexible server deployments, additional IOPS can be provisioned. You can read more about it [here](https://docs.microsoft.com/en-gb/azure/mysql/flexible-server/concepts-compute-storage#iops).

### Monitoring Azure Database for MySQL

By default, Azure Database for MySQL servers has monitoring enabled.
You can monitor database metrics from the Azure portal.
For more information, check the [official documentation](https://docs.microsoft.com/en-us/azure/mysql/concepts-monitoring).

## Azure Database for PostgreSQL

Azure Database for PostgreSQL is a fully managed PostgreSQL database provided by Azure. You can create a PostgreSQL database by selecting a database instance and storage according to your configurations. The IOPS is calculated based on the amount of storage you choose.
In this section, you will create an Azure Database for PostgreSQL.

### Recommendations

* You should select Flexible or Single server deployment for Azure Database for PostgreSQL. You can refer to [official documentation](https://docs.microsoft.com/en-us/azure/postgresql/overview-postgres-choose-server-options) to check and compare which option suits you best.
* You should select a deployment that suits your IOPS requirements.
    * For Single server deployments, IOPS is defined on the amount of storage provisioned(3 IOPS/GB).
    * For Flexible server deployments, additional IOPS can be provisioned and the maximum threshold will be defined by the storage and the database instance chosen.

### Steps

You can follow the [official documentation](https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-database-portal) to create an Azure Database for PostgreSQL server for Single server deployment.
For creating a flexible server deployment for Azure Database for PostgreSQL, you can follow this [official guide](https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal).

### Scale Performance

**Scaling storage**:- You can enable the `storage auto grow` feature to automatically increase storage when it reaches a threshold without impacting the workload. Please note this feature is not yet available for Flexible server deployment for Azure Databases for PostgreSQL.

You can scale resources based on the deployment you choose. For Single server deployment, you can refer to the [official documentation](https://docs.microsoft.com/en-gb/azure/postgresql/concepts-pricing-tiers#scale-resources) for scaling resources.
For Flexible server deployments, additional IOPS can be provisioned. You can read more about maximum IOPS utilization [here](https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage#maximum-iops-for-your-configuration).


### Monitoring Azure Database for PostgreSQL

By default, Azure Database for PostgreSQL servers has monitoring enabled.
You can monitor database metrics from the Azure portal.
For more information, check the [official documentation](https://docs.microsoft.com/en-us/azure/postgresql/concepts-monitoring).
