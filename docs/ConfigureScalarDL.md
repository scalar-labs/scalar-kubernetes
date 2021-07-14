# Configure Scalar DL 

This guide explains how to configure helm charts for Scalar DL deployment.

## Steps

### Cosmos DB

To create Scalar DL schema in Cosmos DB, update the following configuration in [schema-loading-custom-values](../conf/schema-loading-custom-values.yaml)

```yaml
database: cosmos
contactPoints: <Cosmos DB account endpoint>
password: <Cosmos DB account primary master key>
cosmosBaseResourceUnit: 400
```

To deploy Scalar DL on Cosmos DB, update the following configuration in [scalardl-custom-values](../conf/scalardl-custom-values.yaml)

```yaml
dbContactPoints: <Cosmos DB account endpoint>
dbPassword: <Cosmos DB account primary master key>
dbStorage: cosmos
```
