# Set up a database

In this section, you will set up a database for Scalar DL.

## Cosmos DB

You need to create a Cosmos DB account for Scalar DL. In this section, you will set up a Cosmos DB for Scalar DL.

### Requirements

* You must create a Cosmos DB account with `Core(SQL)` API.
* You must change Cosmos DB `Default consistency` to `Strong`.

[Create an Azure Cosmos DB account](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account) with the above requirements.

### Configure Scalar DL

To deploy Scalar DL with Cosmos DB, update the following configuration in `scalardl-custom-values` and `schema-loading-custom-values` files.

```
database: cosmos
contactPoints: <COSMOS_DB_ACCOUNT_URI>
password: <COSMOS_DB_KEY>
cosmosBaseResourceUnit: 400
```

### Scaling Performance

Cosmos DB performance can be adjusted using the following parameters

#### Request Units (RU)

You can scale the throughput of Cosmos DB by specifying cosmosBaseResourceUnit (which applies to all the tables) in schema-loading-custom-values.yaml file. 
Scalardl schema tool abstracts Capacity Unit of Cosmos DB with RU.

#### Auto-scaling

By default, the scalardl schema tool enables auto-scaling of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload.

For example, if you specify RU 10000, RU of each table is scaled in or out between 1000 and 10000.

### Monitor Cosmos DB

By default, monitoring is enabled on Cosmos DB.

More information can be found in [Monitor Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db) documentation.
