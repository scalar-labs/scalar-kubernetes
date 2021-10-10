# Configure Scalar DL

This guide explains how to configure database properties in helm charts for Scalar DL deployment.

## Steps

### Create Kubernetes Secrets

Kubernetes Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. 
This method is highly recommended for handling credentials in the production environment.

You should create a Secret object. The key to store the username should be db-username and the key to store the password should be db-password.

```
# Cosmos DB
    # username=<Account name>
    # password=<Cosmos DB account primary master key>

# DynamoDB
    # username=<AWS_ACCESS_KEY_ID>
    # password=<AWS_ACCESS_SECRET_KEY>

kubectl create secret generic scalardl --from-literal db-username=<username> --from-literal db-password=<password>
```

Then, You should follow the remaining section and you can skip the credential details specified in the Kubernetes Secrets from the custom value files while configuring it in the configuration file.

### Cosmos DB

#### Configure schema-loading-custom-values

To create Scalar DL schema in Cosmos DB, update the [schema-loading-custom-values](../conf/schema-loading-custom-values.yaml) file with `existingSecret` as key and Secret Object as value.
You can skip the key `password` while using the kubernetes secret object.

```yaml
schemaLoading:
  existingSecret: scalardl

  database: cosmos
  contactPoints: <Cosmos DB account endpoint>
  # password: <Cosmos DB account primary master key>
  cosmosBaseResourceUnit: 400
```

#### Configure scalardl-custom-values 

To deploy Scalar Ledger on Cosmos DB, update the [scalardl-custom-values](../conf/scalardl-custom-values.yaml) file with `existingSecret` as key and Secret Object as value.
You can skip the key `dbPassword` while using the kubernetes secret object.

```yaml
ledger:
  existingSecret: scalardl
  ....
  scalarLedgerConfiguration:
    dbContactPoints: <Cosmos DB account endpoint>
    #dbPassword: <Cosmos DB account primary master key>
    dbStorage: cosmos
```

Follow the Enable Auditor [Configure scalardl-custom-values]() section to enable the auditor service.

#### Configure scalardl-audit-custom-values 
To deploy Scalar Ledger on Cosmos DB, update the [scalardl-audit-custom-values](../conf/scalardl-audit-custom-values.yaml) file with `existingSecret` as key and Secret Object as value.
You can skip the key `dbPassword` while using the kubernetes secret object. 

```console
audit:
  existingSecret: scalardl
  ....
  scalarAuditorConfiguration:
    dbContactPoints: <Cosmos DB account endpoint>
    #dbPassword: <Cosmos DB account primary master key>
    dbStorage: cosmos
```

Follow the Enable Auditor Configure [scalardl-audit-custom-values]() section to enable the auditor service.

### DynamoDB

#### Configure schema-loading-custom-values

To create Scalar DL schema in Cosmos DB, update the [schema-loading-custom-values](../conf/schema-loading-custom-values.yaml) file with existingSecret as key and Secret Object as value.
You can skip the key `username` and `password` while using the kubernetes secret object.

```yaml
schemaLoading:
  existingSecret: scalardl

  database: dynamo
  contactPoints: <REGION>
  # username: <AWS_ACCESS_KEY_ID>
  # password: <AWS_ACCESS_SECRET_KEY>
  dynamoBaseResourceUnit: 10
```

#### Configure scalardl-custom-values

To deploy Scalar Ledger on Cosmos DB, update the [scalardl-custom-values](../conf/scalardl-custom-values.yaml) file with existingSecret as key and Secret Object as value.
You can skip the key `dbUsername` and `dbPassword` while using the kubernetes secret object. 

```yaml
ledger:
  existingSecret: scalardl
  ....
  scalarLedgerConfiguration:
    dbStorage: dynamo
    dbContactPoints: <REGION>
    # dbUsername: <AWS_ACCESS_KEY_ID>
    # dbPassword: <AWS_ACCESS_SECRET_KEY>
```

Follow the Enable Auditor Configure [scalardl-custom-values]() section to enable the auditor service.

#### Configure scalardl-audit-custom-values

To deploy Scalar Ledger on Cosmos DB, update the [scalardl-audit-custom-values](../conf/scalardl-audit-custom-values.yaml) file with existingSecret as key and Secret Object as value.
You can skip the key `dbUsername` and `dbPassword` while using the kubernetes secret object.

```yaml
audit:
  existingSecret: scalardl
  ....
  scalarAuditorConfiguration:
    dbStorage: dynamo
    dbContactPoints: <REGION>
    # dbUsername: <AWS_ACCESS_KEY_ID>
    # dbPassword: <AWS_ACCESS_SECRET_KEY>
```

Follow the Enable Auditor [Configure scalardl-audit-custom-values]() section to enable the auditor service.

### Enable Auditor 

#### Configure scalardl-custom-values

To enable the auditor service, enable the following configurations in the scalardl-custom-values file.

```yaml
scalarLedgerConfiguration:
   # To use Auditor
   ledgerProofEnabled: true
   ledgerAuditorEnabled: true
```

#### Configure scalardl-audit-custom-values

Configure the service endpoint of ledger-side envoy in the scalardl-audit-custom-values file.
The service endpoint of the ledger-side envoy is only available after the Scalar DL ledger deployment.

```yaml
scalarAuditorConfiguration:
  # To use Auditor
  auditorLedgerHost: <the service endpoint of ledger-side envoy>
```
