# Set up a database

This guide explains how to set up a database for Scalar DL in Azure and how to configure helm charts for Scalar DL deployment.

## Cosmos DB

In this section, you will set up a Cosmos DB for Scalar DL.

### Requirements

* You must create a Cosmos DB account with `Core(SQL)` API.
* You must change Cosmos DB `Default consistency` to `Strong`.
* You must use Capacity mode as `Provisioned throughput`.

### Steps

* Create an Azure Cosmos DB account on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal#create-an-azure-cosmos-db-account) with the above requirements.

### Configure Scalar DL 

To apply the Scalar DL schema to Cosmos DB, update the following configuration in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml)

```yaml
database: cosmos
contactPoints: <Cosmos DB account endpoint>
password: <Cosmos DB account primary master key>
cosmosBaseResourceUnit: 400
```

To deploy Scalar DL on Cosmos DB, update the following configuration in [scalardl-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/scalardl-custom-values.yaml) 

```yaml
dbContactPoints: <Cosmos DB account endpoint>
dbPassword: <Cosmos DB account primary master key>
dbStorage: cosmos
```

### Scale Performance

Cosmos DB performance can be adjusted using the following parameters.

#### Request Units (RU)

Request unit is a performance currency abstracting the system resources such as CPU, IOPS, and memory that are required to perform the database operations supported by Azure Cosmos DB.
You can scale the throughput of Cosmos DB by specifying `cosmosBaseResourceUnit` (which applies to all the tables) in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml). 
Scalardl schema tool abstracts Request Unit of Cosmos DB with RU. So please set appropriate value.

#### Autoscale

Autoscale provisioned throughput in Azure Cosmos DB allows you to scale the throughput (RU/s) of your database or container automatically and instantly. 
The throughput is scaled based on the usage, without impacting the availability, latency, throughput, or performance of the workload.
By default, the scalardl schema tool enables autoscale of RU for all tables: RU is scaled in or out between 10% and 100% of a specified RU depending on a workload.

### Backup and Restore

Azure Cosmos DB automatically takes backups of your data at regular intervals. The automatic backups are taken without affecting the performance or availability of the database operations. All the backups are stored separately in a storage service. 

More information can be found in [Backup and Restore in Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/online-backup-and-restore) documentation.

### Monitor Cosmos DB

By default, monitoring is enabled on Cosmos DB.

More information can be found in [Monitor Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db) documentation.

## MySQL

In this section, you will set up an Azure Database for MySQL servers for Scalar DL.

### Requirements

* You must create an Azure Database for MySQL servers with the plan `Single server`.

### Steps

* Create an Azure Database for MySQL servers on the base of [Azure official guide](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-portal).

### Configure Scalar DL 

To apply the Scalar DL schema to MySQL, update the following configuration in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml)

```yaml
database: jdbc
contactPoints: <JDBC connection url>
username: <MySQL username>
password: <MySQL password>
```

To deploy Scalar DL on MySQL, update the following configuration in [scalardl-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/scalardl-custom-values.yaml) 

```yaml
dbContactPoints: <JDBC connection url>
dbUsername: <MySQL username>
dbPassword: <MySQL password>
dbStorage: jdbc
```

### Scale resources

After you create your server, you can independently change the vCores, the hardware generation, the pricing tier (except to and from Basic), the amount of storage, and the backup retention period. 
The number of vCores can be scaled up or down. The storage size can only be increased. Scaling of the resources can be done either through the portal or Azure CLI.

#### Storage auto-grow

Storage auto-grow prevents your server from running out of storage and becoming read-only. If storage auto grow is enabled, the storage automatically grows without impacting the workload. 
For servers with less than equal to 100 GB provisioned storage, the provisioned storage size is increased by 5 GB when the free storage is below 10% of the provisioned storage.
For servers with more than 100 GB of provisioned storage, the provisioned storage size is increased by 5% when the free storage space is below the greater of 10 GB or 5% of the provisioned storage size. 

### Backup and Restore

Azure Database for MySQL automatically creates server backups and stores them in user configured locally redundant or geo-redundant storage. Backups can be used to restore your server to a point-in-time. 

More information can be found in [Backup and restore in Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/concepts-backup) documentation.

### Monitor MySQL

By default, monitoring is enabled on Azure Database for MySQL servers.

More information can be found in [Monitoring in Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/concepts-monitoring) documentation.

## PostgreSQL

In this section, you will set up an Azure Database for PostgreSQL servers for Scalar DL.

### Requirements

* You must create an Azure Database for PostgreSQL servers with the plan `Single server`.

### Steps

* Create an Azure Database for PostgreSQL servers on the base of [Azure official guide](https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-database-portal).

### Configure Scalar DL 

To apply the Scalar DL schema to PostgreSQL, update the following configuration in [schema-loading-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/schema-loading-custom-values.yaml)

```yaml
database: jdbc
contactPoints: <PostgreSQL connection url>
username: <PostgreSQL username>
password: <PostgreSQL password>
```

To deploy Scalar DL on PostgreSQL, update the following configuration in [scalardl-custom-values](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/scalardl-custom-values.yaml) 

```yaml
dbContactPoints: <PostgreSQL connection url>
dbUsername: <PostgreSQL username>
dbPassword: <PostgreSQL password>
dbStorage: jdbc
```

### Scale resources

After you create your server, you can independently change the vCores, the hardware generation, the pricing tier (except to and from Basic), the amount of storage, and the backup retention period. 
The number of vCores can be scaled up or down. The storage size can only be increased. Scaling of the resources can be done either through the portal or Azure CLI.

#### Storage auto-grow

Storage auto-grow prevents your server from running out of storage and becoming read-only. If storage auto grow is enabled, the storage automatically grows without impacting the workload. 
For servers with less than equal to 100 GB provisioned storage, the provisioned storage size is increased by 5 GB when the free storage is below 10% of the provisioned storage.
For servers with more than 100 GB of provisioned storage, the provisioned storage size is increased by 5% when the free storage space is below the greater of 10 GB or 5% of the provisioned storage size. 

### Backup and Restore

Azure Database for PostgreSQL automatically creates server backups and stores them in user configured locally redundant or geo-redundant storage. 
Backups can be used to restore your server to a point-in-time. 

More information can be found in [Backup and restore in Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/concepts-backup) documentation.


### Monitor PostgreSQL

By default, monitoring is enabled on Azure Database for PostgreSQL servers.

More information can be found in [Monitor and tune Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/concepts-monitoring) documentation.
