# Configure Scalar DL

This guide explains how to configure Scalar DL custom values in helm charts for Scalar DL deployment.

## Create Kubernetes Secrets

Kubernetes Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. 
This optional method is highly recommended for handling credentials in the production environment.

You need to create a secret object with `db-username` and `db-password` to store the username and password of the underlying database.

```
# Cosmos DB
    # username=<Account name>
    # password=<Cosmos DB account primary master key>

# DynamoDB
    # username=<AWS_ACCESS_KEY_ID>
    # password=<AWS_ACCESS_SECRET_KEY>

# JDBC Databases
   # username=<USERNAME>
   # password=<PASSWORD>
    
kubectl create secret generic scalardl --from-literal db-username=<username> --from-literal db-password=<password>
```

## Update Configuration Files 

### Cosmos DB

#### Configure schema-loading-custom-values

To create a Scalar DL schema in Cosmos DB, you need to update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  existingSecret: scalardl

  database: cosmos
  contactPoints: <Cosmos DB account endpoint>
  cosmosBaseResourceUnit: 400
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  database: cosmos
  contactPoints: <Cosmos DB account endpoint>
  password: <Cosmos DB account primary master key>
  cosmosBaseResourceUnit: 400
```

#### Configure scalardl-custom-values 

To deploy Scalar DL Ledger on Cosmos DB, you need to update the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  existingSecret: scalardl
  ....
  scalarLedgerConfiguration:
    dbContactPoints: <Cosmos DB account endpoint>
    dbStorage: cosmos
```
**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  ....
  scalarLedgerConfiguration:
    dbContactPoints: <Cosmos DB account endpoint>
    dbPassword: <Cosmos DB account primary master key>
    dbStorage: cosmos
```

To enable the Auditor service, you can follow the [Enable Auditor](#enable-auditor) section.

#### Configure scalardl-audit-custom-values

To deploy the Scalar DL Auditor on Cosmos DB, you need to update the [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file.

**With Kubernetes Secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  existingSecret: scalardl
  ....
  scalarAuditorConfiguration:
    dbContactPoints: <Cosmos DB account endpoint>
    dbStorage: cosmos
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  ....
  scalarAuditorConfiguration:
    dbContactPoints: <Cosmos DB account endpoint>
    dbPassword: <Cosmos DB account primary master key>
    dbStorage: cosmos
```

To enable the Auditor service, you can follow the [Enable Auditor](#enable-auditor) section.

### DynamoDB

#### Configure schema-loading-custom-values

To create the Scalar DL schema in DynamoDB, you need to update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  existingSecret: scalardl

  database: dynamo
  contactPoints: <REGION>
  dynamoBaseResourceUnit: 10
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  database: dynamo
  contactPoints: <REGION>
  username: <AWS_ACCESS_KEY_ID>
  password: <AWS_ACCESS_SECRET_KEY>
  dynamoBaseResourceUnit: 10
```

#### Configure scalardl-custom-values

To deploy the Scalar DL Ledger on DynamoDB, you need to update the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  existingSecret: scalardl
  ....
  scalarLedgerConfiguration:
    dbStorage: dynamo
    dbContactPoints: <REGION>
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  ....
  scalarLedgerConfiguration:
    dbStorage: dynamo
    dbContactPoints: <REGION>
    dbUsername: <AWS_ACCESS_KEY_ID>
    dbPassword: <AWS_ACCESS_SECRET_KEY>
```

To enable the Auditor service, you can follow the [Enable Auditor](#enable-auditor) section.

#### Configure scalardl-audit-custom-values

To deploy the Scalar DL Auditor on DynamoDB, you need to update the [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  existingSecret: scalardl
  ....
  scalarAuditorConfiguration:
    dbStorage: dynamo
    dbContactPoints: <REGION>
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  ....
  scalarAuditorConfiguration:
    dbStorage: dynamo
    dbContactPoints: <REGION>
    dbUsername: <AWS_ACCESS_KEY_ID>
    dbPassword: <AWS_ACCESS_SECRET_KEY>
```

To enable the Auditor service, you can follow the [Enable Auditor](#enable-auditor) section.

### JDBC Databases

#### Configure schema-loading-custom-values

To create the Scalar DL schema in JDBC databases, you need to update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  existingSecret: scalardl

  database: jdbc
  contactPoints: <JDBC_CONNECTION_URL>
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  database: jdbc
  contactPoints: <JDBC_CONNECTION_URL>
  username: <USERNAME>
  password: <PASSWORD>
```

#### Configure scalardl-custom-values

To deploy the Scalar DL Ledger on JDBC databases, you need to update the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  existingSecret: scalardl
  ....
  scalarLedgerConfiguration:
    dbStorage: jdbc
    dbContactPoints: <JDBC_CONNECTION_URL>
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  ....
  scalarLedgerConfiguration:
    dbStorage: jdbc
    dbContactPoints: <JDBC_CONNECTION_URL>
    dbUsername: <USERNAME>
    dbPassword: <PASSWORD>
```

To enable the Auditor service, you can follow the [Enable Auditor](#enable-auditor) section.

#### Configure scalardl-audit-custom-values

To deploy the Scalar DL Auditor on JDBC databases, you need to update the [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  existingSecret: scalardl
  ....
  scalarAuditorConfiguration:
    dbStorage: jdbc
    dbContactPoints: <JDBC_CONNECTION_URL>
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  ....
  scalarAuditorConfiguration:
    dbStorage: jdbc
    dbContactPoints: <JDBC_CONNECTION_URL>
    dbUsername: <USERNAME>
    dbPassword: <PASSWORD>
```

### Enable Auditor 

#### Configure scalardl-custom-values

To enable the Auditor service, update the following configurations in the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) file.

```yaml
scalarLedgerConfiguration:
   # To use Auditor
   ledgerProofEnabled: true
   ledgerAuditorEnabled: true
```

#### Configure scalardl-audit-custom-values

Configure the service endpoint of ledger-side envoy in the [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file.

```yaml
scalarAuditorConfiguration:
  # To use Auditor
  auditorLedgerHost: <the service endpoint of ledger-side envoy>
```
