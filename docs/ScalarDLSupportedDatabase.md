# Set up a database

This guide explains how to set up a database for Scalar DL in AWS and how to configure helm charts for Scalar DL deployment.

## DynamoDB

By default, Amazon DynamoDB is available for all AWS users. You do not need to configure anything manually.
Scalardl schema tool [helm charts](https://github.com/scalar-labs/helm-charts/tree/main/charts/schema-loading) will help you to configure DynamoDB.

### Configure Scalar DL

To deploy Schema loading with DynamoDB, update the following configuration in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml)

```yaml
dbStorage: dynamo
dbContactPoints: <REGION>
dbUsername: <AWS_ACCESS_KEY_ID>
dbPassword: <AWS_ACCESS_SECRET_KEY>
dynamoBaseResourceUnit: 10
```   

To deploy Scalar DL with DynamoDB, update the following configuration in [scalardl-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/scalardl-custom-values.yaml) 

```yaml
database: dynamo
contactPoints: <REGION>
username: <AWS_ACCESS_KEY_ID>
password: <AWS_ACCESS_SECRET_KEY>
```

### Scale Performance

DynamoDB performance can be adjusted using the following parameters

#### Request Units (RU)

You can scale the throughput of DynamoDB by specifying `dynamoBaseResourceUnit` (which applies to all the tables) in the `schema-loading-custom-values.yaml` file.
Scalardl schema tool abstracts Capacity Unit of DynamoDB with RU.

#### Auto-scaling

By default, the `scalardl schema tool` enables auto-scaling of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload. 

For example, if you specify RU 10000, the RU of each table is scaled in or out between 1000 and 10000.

WARNING:

* Scalar schema tool sets the same value to both Read and Write Request Units.
* By default, the Read and Write Request Unit is 10. 

### Monitor DynamoDB

By default, monitoring is enabled on DynamoDB

More information can be found in [DynamoDB Metrics and Dimensions](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/metrics-dimensions.html) documentation.
