# Configure Scalar DL

This guide explains how to configure Scalar DL custom values in helm charts for Scalar DL deployment.

## Update Configuration Files

### Kubernetes Secrets and Schema Loading reference

You can refer to the table below to get values to set create Kubernetes Secrets and update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file properties file according to the database you chose for deployment.

| Database  | database | contactPoints              | username          | password                             | dynamoBaseResourceUnit | cosmosBaseResourceUnit | 
|:----------|----------|----------------------------|-------------------|--------------------------------------|------------------------|------------------------|
| DynamoDB  | dynamo   | REGION                     | AWS_ACCESS_KEY_ID | AWS_ACCESS_SECRET_KEY                | 10                     | N/A                    |
| Cosmos DB | cosmos   | Cosmos DB account endpoint | N/A               | Cosmos DB account primary master key | N/A                    | 400                    |
| JDBC      | jdbc     | JDBC_CONNECTION_URL        | USERNAME          | PASSWORD                             | N/A                    | N/A                    |


### Create Kubernetes Secrets

Kubernetes Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key.
This optional method is highly recommended for handling credentials in the production environment.
You can refer to the [section](#kubernetes-secret-and-schema-loading-reference) to get the values for `username` and `password` for the database you chose.
You need to create a secret object with `db-username` and `db-password` to store the username and password of the underlying database.


```
kubectl create secret generic scalardl --from-literal db-username=<username> --from-literal db-password=<password>
```
Note-:

For Cosmos DB, use the account name as `username` since we can't leave the `db-uername` property empty.

### Configure schema-loading-custom-values

To create a Scalar DL schema in Cosmos DB, you need to update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file.
You can refer to the [section](#kubernetes-secret-and-schema-loading-reference) to check which values are needed based on the database used.
If any configuration property value is defined as `N/A` in the reference table for your database, you can remove that property from the configuration file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  existingSecret: scalardl
  
  database: <database>
  contactPoints: <dbContactPoints>
  cosmosBaseResourceUnit: <cosmosBaseResourceUnit>
  dynamoBaseResourceUnit: <dynamoBaseResourceUnit>
  
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  database: <database>
  contactPoints: <dbContactPoints>
  username: <username>
  password: <password>
  cosmosBaseResourceUnit: <cosmosBaseResourceUnit>
  dynamoBaseResourceUnit: <dynamoBaseResourceUnit>
```

### Ledger and Auditor reference

You can refer the table below to update the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) and [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file according to the database of you chose for deployment.

| Database  | dbStorage | dbContactPoints            | dbUsername        | dbPassword                           |
|:----------|-----------|----------------------------|-------------------|--------------------------------------|
| DynamoDB  | dynamo    | REGION                     | AWS_ACCESS_KEY_ID | AWS_ACCESS_SECRET_KEY                |
| Cosmos DB | cosmos    | Cosmos DB account endpoint | N/A               | Cosmos DB account primary master key |
| JDBC      | jdbc      | JDBC_CONNECTION_URL        | USERNAME          | PASSWORD                             |


### Configure scalardl-custom-values

To deploy Scalar DL Ledger on Cosmos DB, you need to update the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) file.
You can refer to the [section](#ledger-and-auditor-reference) to check which values are needed based on the database used.
If any configuration property value is defined as `N/A` in the reference table for your database, you can remove that property from the configuration file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  existingSecret: scalardl
  ....
  scalarLedgerConfiguration:
    dbContactPoints: <dbContactPoints>
    dbStorage: <dbStorage>
```
**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  ....
  scalarLedgerConfiguration:
    dbContactPoints: <dbContactPoints>
    dbUsername: <dbUsername>
    dbPassword: <dbPassword>
    dbStorage: <dbStorage>
```

### Configure scalardl-audit-custom-values

To deploy the Scalar DL Auditor on Cosmos DB, you need to update the [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file.
You can refer to the [section](#ledger-and-auditor-reference) to check which values are needed based on the database used.
If any configuration property value is defined as `N/A` in the reference table for your database, you can remove that property from the configuration file.

**With Kubernetes Secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  existingSecret: scalardl
  ....
  scalarAuditorConfiguration:
    dbContactPoints: <dbContactPoints>
    dbStorage: <dbStorage>
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  ....
  scalarAuditorConfiguration:
    dbContactPoints: <dbContactPoints>
    dbUsername: <dbUsername>
    dbPassword: <dbPassword>
    dbStorage: <dbStorage>
```

## Enable Auditor

### Configure scalardl-custom-values

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
