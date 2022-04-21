# Set up a database for Scalar DB/Scalar DL deployment on AWS

This guide explains how to set up a database for Scalar DB/Scalar DL deployment on AWS.

## DynamoDB

By default, Amazon DynamoDB is available for all AWS users. You do not need to configure anything manually.
Scalar schema loader [helm charts](https://github.com/scalar-labs/helm-charts/tree/main/charts/schema-loading) will help you to configure DynamoDB.

* (Optional) You can scale the throughput of DynamoDB by setting the `dynamoBaseResourceUnit` value (which applies to all the tables) in the `schema-loading-custom-values.yaml` file.
* (Optional)  Configure advanced monitoring services with [Azure official guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/monitoring-automated-manual.html), by default monitoring is enabled in DynamoDB.

WARNING:

* Scalar schema loader sets the same value to both Read and Write Request Units.
* By default, the Read and Write Request Unit is 10.

Note:-

* By default, the `scalar DL schema loader` enables auto-scaling of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload.