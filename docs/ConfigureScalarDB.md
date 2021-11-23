# Configure Scalar DB Server

This guide explains how to create database schema and configure database properties in helm charts for Scalar DB server deployment.

## Create schema
There are two methods to create the schema for the scalar DB server.

### Using Scalar DB Schema Loader

Scalar DB Schema Loader lets you create or delete a scalar DB schema based on a provided schema file.
The released versions of `scalar DB schema loader` can be downloaded from [releases] page(https://github.com/scalar-labs/scalardb/releases).
It is also possible to deploy it in a docker using a docker image pulled from [Scalar's container registry](https://github.com/orgs/scalar-labs/packages/container/package/scalardb-schema-loader) or building a [docker image](https://github.com/scalar-labs/scalardb/tree/master/schema-loader#docker) from the source.
A scalar DB schema can be created/deleted using scalar DB schema loader by specifying general cli options in 2 ways, either by passing a configuration file or by passing options directly to the cli in command.

#### Using configuration file
You can create a schema by passing a Scalar DB [configuration file](https://github.com/scalar-labs/scalardb/blob/master/conf/database.properties) and database/storage-specific options additionally.
To create a cosmos DB schema using Scalar DB schema loader with Scalar DB schema loader by passing a config file to general cli using the command below.

```console
$ java -jar scalardb-schema-loader-<version>.jar --config <PATH_TO_CONFIG_FILE> -f schema.json
```


#### Passing options directly to cli

You can create a schema by providing the options directly in the cli command.

1. For Cosmos DB

You can create a cosmos DB schema using Scalar DB schema loader by passing options to general cli using the command below.

```console
$ java -jar scalardb-schema-loader-<version>.jar --cosmos -h <COSMOS_DB_ACCOUNT_URI> -p <COSMOS_DB_KEY> -f schema.json [-r BASE_RESOURCE_UNIT]
```

2. For DyanmoDB

You can create a dynamoDB schema using Scalar DB schema loader by passing options to general cli using the command below.

```console
$ java -jar scalardb-schema-loader-<version>.jar --dynamo -u <AWS_ACCESS_KEY_ID> -p <AWS_ACCESS_SECRET_KEY> --region <REGION> -f schema.json [-r BASE_RESOURCE_UNIT]
```

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

### Create Kubernetes Secrets

Kubernetes Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key.
This method is recommended highly for handling credentials in the production environment.

First, you should create a Secret object. The key to store the username should be db-username and the key to store the password should be db-password.

```
# Cosmos DB
    # username=<Account name>
    # password=<Cosmos DB account primary master key>

# DynamoDB
    # username=<AWS_ACCESS_KEY_ID>
    # password=<AWS_ACCESS_SECRET_KEY>

kubectl create secret generic scalardb --from-literal db-username=<username> --from-literal db-password=<password>
```

Next, update each configuration file with `existingSecret` as key and Secret Object as value.

[scalardb-custom-values](../conf/scalardb-custom-values.yaml)

```yaml
existingSecret: scalardb
```

Then, You should follow the remaining section and skip the credential details specified in the Kubernetes Secrets from the custom value files.

### Cosmos DB

To set up Scalar DB server for Cosmos DB, update the following configuration in [scalardb-custom-values](../conf/scalardb-custom-values.yaml) file.

* You can skip configuring the `password` while using the [Create Kubernetes Secrets](#create-kubernetes-secrets) section.

```yaml
contactPoints: <Cosmos DB account endpoint>
password: <Cosmos DB account primary master key>
storage: cosmos
```
### DynamoDB

To set up Scalar DB server for DynamoDB, update the following configuration in [scalardb-custom-values](../conf/scalardb-custom-values.yaml) file.

* You can skip configuring the `password` while using the [Create Kubernetes Secrets](#create-kubernetes-secrets) section.

```yaml
contactPoints: <REGION>
username: <AWS_ACCESS_KEY_ID>
password: <AWS_ACCESS_SECRET_KEY>
storage: dynamo
```
