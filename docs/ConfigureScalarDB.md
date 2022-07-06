# Configure Scalar DB Server

This guide explains how to create database schema and configure database properties in helm charts for Scalar DB server deployment.

## Create schema
You can use the scalar DB schema loader to create the schema for the scalar DB server.

### Using Scalar DB Schema Loader

Scalar DB Schema Loader lets you create or delete a scalar DB schema based on a provided schema file.
The released versions of the `scalar DB schema loader` can be downloaded from the [releases](https://github.com/scalar-labs/scalardb/releases) page.
To create a schema for the scalar DB server using the scalar DB schema loader, please follow the instructions provided in this [guide](https://github.com/scalar-labs/scalardb/blob/master/schema-loader/README.md).

## Configure database properties

To deploy the scalar DB server via helm charts, you need to configure the scalar DB server according to the database selection.

### Reference Table

You can refer to the table below to get values to create Kubernetes Secrets and update the [schema-loading-custom-values.yaml](../conf/schema-loading-custom-values.yaml) file according to the database you chose

| Database  | storageType | contactPoints              | username       | password                                 | dynamoBaseResourceUnit | cosmosBaseResourceUnit | 
|:----------|-------------|----------------------------|----------------|------------------------------------------|------------------------|------------------------|
| DynamoDB  | dynamo      | AWS_REGION                 | AWS_ACCESS_KEY | AWS_ACCESS_SECRET_KEY                    | 10                     | N/A                    |
| Cosmos DB | cosmos      | Cosmos DB account endpoint | N/A            | Cosmos DB account primary/secondary key  | N/A                    | 400                    |
| JDBC      | jdbc        | JDBC_CONNECTION_URL        | USERNAME       | PASSWORD                                 | N/A                    | N/A                    |

Note:
* JDBC denotes all relational databases supported by Scalar DL such as MySQL, PostgreSQL, Oracle Database, SQL Server, and Amazon Aurora.

### Create Kubernetes Secrets

Kubernetes Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key.
This optional method is recommended highly for handling credentials in the production environment.
You can refer to the [section](#reference-table) to get the values for `username` and `password` for the database you chose.
You need to create a secret object with `db-username` and `db-password` to store the username and password of the underlying database.

```
kubectl create secret generic scalardb-secret --from-literal db-username=<username> --from-literal db-password=<password>
```

After creating the Secret Object, update [scalardb-custom-values](../conf/scalardb-custom-values.yaml)  configuration file with `existingSecret` as key and Secret Object as value.

[scalardb-custom-values](../conf/scalardb-custom-values.yaml)

  ```yaml
  scalardb:
    ....
    ....
    existingSecret: scalardb-secret
  ```

Note:

* Kubernetes secrets option to add database credentials as `existingSecret` may not be available with the current version. It will be added in future releases.
* For Cosmos DB, use a dummy username like `dummy-user` for `db-username` as there is no username property for Cosmos DB.

### Configure scalardb-custom-values

To set up Scalar DB server for Cosmos DB, update the following configuration in [scalardb-custom-values](../conf/scalardb-custom-values.yaml) file.

  ```yaml
  storageConfiguration:
    contactPoints: <contactPoints>
    username: <username>
    password: <password>
    storage: <storageType>
  ```

Note:-

* You can skip configuring the `username` and `password` if you set the Secret Object as per the [Create Kubernetes Secrets](#create-kubernetes-secrets) section.
