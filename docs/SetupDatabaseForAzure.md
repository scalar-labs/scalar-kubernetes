# Set up a database for Scalar DB/Scalar DL deployment in Azure

This guide explains how to set up a database for Scalar DB/Scalar DL deployment in Azure.

## Cosmos DB

In this section, you will create a Cosmos DB account.

### Requirements

* You must create a Cosmos DB account with the `Core(SQL)` API.
* You must change Cosmos DB `Default consistency` to `Strong`.
* You must use Capacity mode as `Provisioned throughput`.

### Recommendations

* You should configure the backup policy as `Continuous` for Point-in-time-restore (PITR).
* You should configure the service endpoint based on the [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-configure-vnet-service-endpoint) to restrict access to Cosmos DB for production.

### Steps

* Create an Azure Cosmos DB account based on the [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account) with the above requirements.

Optional steps:-

* Configure advanced monitoring services with [Monitor Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db) guide, by default monitoring (metrics) will be enabled in Cosmos DB.
* Update the `cosmosBaseResourceUnit` value in the [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml) to scale the throughput of Cosmos DB.

Note:-

* The [scalardl-schema-loader](https://github.com/scalar-labs/scalardl-schema-loader) applies `cosmosBaseResourceUnit` value (the default value is 10) to all tables.
* The scalardl-schema-loader enables autoscale of [Request Units](https://docs.microsoft.com/en-us/azure/cosmos-db/request-units) (RU) for all tables.


## Azure Database for MySQL

In this section, you will create an Azure Database for MySQL.

### Steps

You can choose Flexible or Single server deployment for Azure Database for MySQL, follow the [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/select-right-deployment-type) to learn more.

* For creating an Azure Database for MySQL, 
  * For Single Server deployment, follow this [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-portal).
  * For creating a flexible server deployment, follow this [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/quickstart-create-server-portal).

Optional steps:-

* Configure advanced monitoring services with [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/concepts-monitoring), monitoring (metrics) is enabled in Azure Database for MySQL by default.
* To scale resources like vCores and storage after the deployment from the Azure portal,
  * Follow the [Azure official guide](https://docs.microsoft.com/en-gb/azure/mysql/concepts-pricing-tiers#scale-resources) for learning more about scaling single server resources.
  * Follow the [Azure official guide](https://docs.microsoft.com/en-gb/azure/mysql/flexible-server/concepts-compute-storage#scale-resources) for learning more about scaling flexible server resources.
  
Note:-

* The [Storage auto-grow](https://docs.microsoft.com/en-gb/azure/mysql/concepts-pricing-tiers#storage-auto-grow) feature automatically increases storage without impacting the workload, is enabled by default in server configuration while creating an Azure Database for MySQL instance.
