# Configure Scalar DB Server

This guide explains how to create database schema and configure database properties in helm charts for Scalar DB server deployment.

## Create schema
There are m2 methods to create schema for scalar DB server.

###Using Scalar DB Schema Loader
Scalar DB schema loader is a part of scalar DB, which lets you create a schema in the database.
To create database schema, [schema loader for Scalar DB](https://github.com/scalar-labs/scalardb/tree/master/schema-loader), follow this [file](https://github.com/scalar-labs/scalardb/blob/master/schema-loader/README.md) to create the database schema.

### Using Scalar schema tool
Scalar schema tool is a standalone tool, which lets you create a schema in your database.
You can download the appropriate version of Scalar schema tool from [here](https://github.com/scalar-labs/scalardb/releases).

#### For Cosmos DB
To create a Cosmos DB database schema using the Scalar schema tool, use the following command.
```console
$ java -jar scalar-schema-standalone-<version>.jar --cosmos -h <COSMOS_DB_ACCOUNT_URI> -p <COSMOS_DB_KEY> -f schema.json [-r BASE_RESOURCE_UNIT]
```

#### For DynamoDB

To create a DynamoDB database schema using the Scalar schema tool, use the following command.
```console
$ java -jar scalar-schema-standalone-<version>.jar --dynamo -u <AWS_ACCESS_KEY_ID> -p <AWS_ACCESS_SECRET_KEY> --region <REGION> -f schema.json [-r BASE_RESOURCE_UNIT]
```

## Configure database properties

To deploy the scalar DB server via helm charts, you need to configure the scalar DB server according to the database selection.

### Cosmos DB

To set up Scalar DB server for Cosmos DB, update the following configuration in [scalardb-custom-values](../conf/scalardb-custom-values.yaml) file.

```yaml
contactPoints: <Cosmos DB account endpoint>
password: <Cosmos DB account primary master key>
storage: cosmos
```
### DynamoDB

To set up Scalar DB server for DynamoDB, update the following configuration in [scalardb-custom-values](../conf/scalardb-custom-values.yaml) file.

```yaml
contactPoints: <REGION>
username: <AWS_ACCESS_KEY_ID>
password: <AWS_ACCESS_SECRET_KEY>
storage: dynamo
```
