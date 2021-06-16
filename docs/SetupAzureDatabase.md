# Set up a database

This guide explains how to set up a database for Scalar DL in Azure and how to configure helm charts for Scalar DL deployment.

## Cosmos DB

You need to create a Cosmos DB account for Scalar DL. In this section, you will set up a Cosmos DB for Scalar DL.

### Requirements

* You must create a Cosmos DB account with `Core(SQL)` API.
* You must change Cosmos DB `Default consistency` to `Strong`.
* You must use Capacity mode as `Provisioned throughput`.

### Procedures

[Create an Azure Cosmos DB account](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account) with the above requirements.

### Configure Scalar DL 

To deploy Schema loading with CosmoDB, update the following configuration in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml)

```yaml
database: cosmos
contactPoints: <Cosmos DB account endpoint>
password: <Cosmos DB account primary master key>
cosmosBaseResourceUnit: 400
```

To deploy Scalar DL with CosmosDB, update the following configuration in [scalardl-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/scalardl-custom-values.yaml) 

```yaml
dbContactPoints: <Cosmos DB account endpoint>
dbPassword: <Cosmos DB account primary master key>
dbStorage: cosmos
```

### Scale Performance

Cosmos DB performance can be adjusted using the following parameters

#### Request Units (RU)

You can scale the throughput of Cosmos DB by specifying cosmosBaseResourceUnit (which applies to all the tables) in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml). 
Scalardl schema tool abstracts Request Unit of Cosmos DB with RU. So please set appropriate value.

#### Auto-scaling

By default, the scalardl schema tool enables auto-scaling of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload.

### Monitor Cosmos DB

By default, monitoring is enabled on Cosmos DB.

More information can be found in [Monitor Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db) documentation.
