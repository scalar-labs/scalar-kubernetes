# Set up a Scalar DL supported database

Scalar DL can run on various databases. You can choose any one of the supported databases based on your convenience. 

## DynamoDB

Scalar DL supports DynamoDB as underlying database. 
By default, Amazon DynamoDB is available for all AWS users, so you do not need to configure anything manually.
Scalardl schema tool will help you to configure DynamoDB.

### Scaling Performance

#### Request Units (RU)

You can scale the throughput of DynamoDB by specifying `dynamoBaseResourceUnit` (which applies to all the tables) in  `schema-loading-custom-values.yaml` file.
Scalardl schema tool abstracts Capacity Unit of DynamoDB with RU.

#### Auto-scaling
By default, the scalardl schema tool enables auto-scaling of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload. 

For example, if you specify RU 10000, RU of each table is scaled in or out between 1000 and 10000.


> **WARNING:**
>
> * Scalar schema tool sets the same value to both Read and Write Request Units.
> * By default, Read and Write Request Unit is 10.
 

### Monitor DynamoDB

By default, monitoring is enabled on DynamoDB

More information can be found in [DynamoDB Metrics and Dimensions](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/metrics-dimensions.html) documentation.
 
### Configure Scalar DL

Scalar DL configuration for DynamoDB

```
database: dynamo
contactPoints: <REGION>
username: <AWS_ACCESS_KEY_ID>
password: <AWS_ACCESS_SECRET_KEY>
dynamoBaseResourceUnit: 10
```
