# Configure Scalar DL

This guide explains how to configure database properties in helm charts for Scalar DL deployment.

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

### DynamoDB

To create Scalar DL schema in Cosmos DB, update the following configuration in [schema-loading-custom-values](../conf/schema-loading-custom-values.yaml)

```yaml
dbStorage: dynamo
dbContactPoints: <REGION>
dbUsername: <AWS_ACCESS_KEY_ID>
dbPassword: <AWS_ACCESS_SECRET_KEY>
dynamoBaseResourceUnit: 10
```

To deploy Scalar DL on Cosmos DB, update the following configuration in [scalardl-custom-values](../conf/scalardl-custom-values.yaml)

```yaml
database: dynamo
contactPoints: <REGION>
username: <AWS_ACCESS_KEY_ID>
password: <AWS_ACCESS_SECRET_KEY>
```
