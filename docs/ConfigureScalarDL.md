# Configure Scalar DL

This guide explains how to configure database properties in helm charts for Scalar DL deployment.

## Steps

### Create Kubernetes Secrets

Kubernetes Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. 
This method is highly recommended for handling credentials in the production environment.

First, you should create a Secret object. The key to store the username should be db-username and the key to store the password should be db-password.

```
# Cosmos DB
    # username=<Account name>
    # password=<Cosmos DB account primary master key>

# DynamoDB
    # username=<AWS_ACCESS_KEY_ID>
    # password=<AWS_ACCESS_SECRET_KEY>

kubectl create secret generic scalardl --from-literal db-username=<username> --from-literal db-password=<password>
```

Next, update each configuration file with `existingSecret` as key and Secret Object as value.

[schema-loading-custom-values](../conf/schema-loading-custom-values.yaml)

```yaml
schemaLoading:
  existingSecret: scalardl
```

[scalardl-custom-values](../conf/scalardl-custom-values.yaml)

```yaml
ledger:
  existingSecret: scalardl
```

Then, You should follow the remaining section and you can skip the credential details specified in the Kubernetes Secrets from the custom value files.

### Cosmos DB

To create Scalar DL schema in Cosmos DB, update the following configuration in [schema-loading-custom-values](../conf/schema-loading-custom-values.yaml)

* You can skip configuring the `password` while using the [Create Kubernetes Secrets](#create-kubernetes-secrets) section.

```yaml
database: cosmos
contactPoints: <Cosmos DB account endpoint>
password: <Cosmos DB account primary master key>
cosmosBaseResourceUnit: 400
```

To deploy Scalar DL on Cosmos DB, update the following configuration in [scalardl-custom-values](../conf/scalardl-custom-values.yaml)

* You can skip configuring the `dbPassword` while using the [Create Kubernetes Secrets](#create-kubernetes-secrets) section.

```yaml
dbContactPoints: <Cosmos DB account endpoint>
dbPassword: <Cosmos DB account primary master key>
dbStorage: cosmos
```

### DynamoDB

To create Scalar DL schema in DynamoDB, update the following configuration in [schema-loading-custom-values](../conf/schema-loading-custom-values.yaml)

* You can skip configuring the `username` and `password` while using the [Create Kubernetes Secrets](#create-kubernetes-secrets) section.

```yaml
database: dynamo
contactPoints: <REGION>
username: <AWS_ACCESS_KEY_ID>
password: <AWS_ACCESS_SECRET_KEY>
dynamoBaseResourceUnit: 10
```

To deploy Scalar DL on DynamoDB, update the following configuration in [scalardl-custom-values](../conf/scalardl-custom-values.yaml)

* You can skip configuring the `dbUsername` and `dbPassword` while using the [Create Kubernetes Secrets](#create-kubernetes-secrets) section.

```yaml
dbStorage: dynamo
dbContactPoints: <REGION>
dbUsername: <AWS_ACCESS_KEY_ID>
dbPassword: <AWS_ACCESS_SECRET_KEY>
```
