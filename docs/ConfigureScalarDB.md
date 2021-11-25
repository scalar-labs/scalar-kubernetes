# Configure Scalar DB Server

This guide explains how to create database schema and configure database properties in helm charts for Scalar DB server deployment.

## Create schema
You can use the scalar DB schema loader to create the schema for the scalar DB server.

### Using Scalar DB Schema Loader

Scalar DB Schema Loader lets you create or delete a scalar DB schema based on a provided schema file.
The released versions of `scalar DB schema loader` can be downloaded from [releases](https://github.com/scalar-labs/scalardb/releases) page.
To create a schema for scalar DB server using scalar DB schema loader, please follow the instructions provided in this [file](https://github.com/scalar-labs/scalardb/blob/master/schema-loader/README.md).

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

kubectl create secret generic scalardb-secret --from-literal db-username=<username> --from-literal db-password=<password>
```

Next, update [scalardb-custom-values](../conf/scalardb-custom-values.yaml)  configuration file with `existingSecret` as key and Secret Object as value.

[scalardb-custom-values](../conf/scalardb-custom-values.yaml)

```yaml
scalardb:
  existingSecret: scalardb-secret
```

Note:
* Kubernetes secrets option to add database credentials as `existingSecret` may not be available with the current version. It will be added in the upcoming releases.

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
