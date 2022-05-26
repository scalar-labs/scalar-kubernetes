# Configure Scalar DL

This guide explains how to configure Scalar DL custom values in helm charts for Scalar DL deployment.


## Reference Table

You can refer to the table below to get values to create Kubernetes Secrets and update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file according to the database you chose

| Database  | storageType | contactPoints              | username       | password                                 | dynamoBaseResourceUnit | cosmosBaseResourceUnit | 
|:----------|-------------|----------------------------|----------------|------------------------------------------|------------------------|------------------------|
| DynamoDB  | dynamo      | REGION                     | AWS_ACCESS_KEY | AWS_ACCESS_SECRET_KEY                    | 10                     | N/A                    |
| Cosmos DB | cosmos      | Cosmos DB account endpoint | N/A            | Cosmos DB account primary/secondary key  | N/A                    | 400                    |
| JDBC      | jdbc        | JDBC_CONNECTION_URL        | USERNAME       | PASSWORD                                 | N/A                    | N/A                    |

Note:- 

* JDBC denotes all relational databases supported by Scalar DL such as 
  * MySQL, PostgreSQL, Oracle DB and SQL Server 
  * AWS RDS for MySQL/PostgreSQL/Oracle/SQL Server
  * Azure Database for MySQL/PostgreSQL.
* For Azure Database for PostgreSQL, please add `/postgres` after the port number (example: `jdbc:postgresql://connection_endpoint:5432/postgres`) for `JDBC_CONNECTION_URL`.

## Create Kubernetes Secrets

Kubernetes Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key.
This optional method is recommended highly for handling credentials in the production environment.
You can refer to the [section](#reference-table) to get the values for `username` and `password` for the database you chose.
You need to create a secret object with `db-username` and `db-password` to store the username and password of the underlying database.


```
kubectl create secret generic scalardl --from-literal db-username=<username> --from-literal db-password=<password>
```
Note-:

For Cosmos DB, use the Cosmos DB account name as `username`.

## Update Configuration Files

### Configure schema-loading-custom-values

To create a Scalar DL schema in the database, you need to update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file.
You can refer to the [section](#reference-table) to check which values are needed based on the database used.
If any configuration property value is defined as `N/A` in the reference table for your database, you need to remove that property from the configuration file.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  existingSecret: scalardl
  
  database: <storageType>
  contactPoints: <contactPoints>
  cosmosBaseResourceUnit: <cosmosBaseResourceUnit>
  dynamoBaseResourceUnit: <dynamoBaseResourceUnit>
  
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
schemaLoading:
  database: <storageType>
  contactPoints: <contactPoints>
  username: <username>
  password: <password>
  cosmosBaseResourceUnit: <cosmosBaseResourceUnit>
  dynamoBaseResourceUnit: <dynamoBaseResourceUnit>
```

### Configure scalardl-custom-values

To deploy Scalar DL Ledger, you need to update the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) file.
You can refer to the [section](#reference-table) to check which values are needed based on the database used.

**With Kubernetes secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  existingSecret: scalardl
  ....
  scalarLedgerConfiguration:
    dbContactPoints: <contactPoints>
    dbStorage: <storageType>
```
**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
ledger:
  ....
  scalarLedgerConfiguration:
    dbContactPoints: <contactPoints>
    dbUsername: <username>
    dbPassword: <password>
    dbStorage: <storageType>
```

Note:-

For Cosmos DB, you need to remove `username` property as it is not required.

### Configure scalardl-audit-custom-values

To deploy the Scalar DL Auditor, you need to update the [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file.
You can refer to the [section](#reference-table) to check which values are needed based on the database used.

**With Kubernetes Secrets**

If you have created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  existingSecret: scalardl
  ....
  scalarAuditorConfiguration:
    dbContactPoints: <contactPoints>
    dbStorage: <storageType>
```

**Without Kubernetes secrets**

If you have not created the `scalardl` Kubernetes secret, you can use the following configuration.

```yaml
auditor:
  ....
  scalarAuditorConfiguration:
    dbContactPoints: <contactPoints>
    dbUsername: <username>
    dbPassword: <password>
    dbStorage: <storageType>
```

Note:-

For Cosmos DB, you need to remove the `username` property as it is not required.

## Enable Auditor

### Configure scalardl-custom-values

To enable the Auditor service, update the following configurations in the [scalardl-custom-values.yaml](../conf/scalardl-custom-values.yaml) file.

```yaml
scalarLedgerConfiguration:
   # To use Auditor
   ledgerProofEnabled: true
   ledgerAuditorEnabled: true
```

### Configure scalardl-audit-custom-values

Configure the service endpoint of ledger-side envoy in the [scalardl-audit-custom-values.yaml](../conf/scalardl-audit-custom-values.yaml) file.

```yaml
scalarAuditorConfiguration:
  # To use Auditor
  auditorLedgerHost: <the service endpoint of ledger-side envoy>
```
