# Set up a database for ScalarDB/ScalarDL deployment on Azure

This guide explains how to set up a database for ScalarDB/ScalarDL deployment on Azure.

## Azure Cosmos DB for NoSQL

### Authentication method

When you use Cosmos DB for NoSQL, you must set `COSMOS_DB_URI` and `COSMOS_DB_KEY` in the ScalarDB/ScalarDL properties file as follows.

```properties
scalar.db.contact_points=<COSMOS_DB_URI>
scalar.db.password=<COSMOS_DB_KEY>
scalar.db.storage=cosmos
```

Please refer to the following document for more details on the properties for Cosmos DB for NoSQL.

* [Configure ScalarDB for Cosmos DB for NoSQL](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb.md#configure-scalardb-1)

### Required configuration/steps

#### Create an Azure Cosmos DB account

You must create an Azure Cosmos DB account with the NoSQL (core) API. You must set the **Capacity mode** as **Provisioned throughput** when you create it. Please refer to the official document for more details.

* [Quickstart: Create an Azure Cosmos DB account, database, container, and items from the Azure portal](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/quickstart-portal)

#### Configure a default consistency configuration

You must set the **Default consistency level** as **Strong**. Please refer to the official document for more details.

* [Configure the default consistency level](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/how-to-manage-consistency#config/ure-the-default-consistency-level)

### Optional configurations/steps

#### Configure backup configurations (Recommended in the production environment)

You can configure **Backup modes** as **Continuous backup mode** for PITR. Please refer to the official document for more details.

* [Backup modes](https://learn.microsoft.com/en-us/azure/cosmos-db/online-backup-and-restore#backup-modes)

It is recommended since the continuous backup mode automatically and continuously gets backups so that we can reduce downtime (pause duration) for backup operations. Please refer to the following document for more details on how to backup/restore the Scalar product data.

* [Backup restore guide for Scalar products](./BackupRestoreGuide.md)

#### Configure monitoring (Recommended in the production environment)

You can configure the monitoring of Cosmos DB using its native feature. Please refer to the official document for more details.

* [Monitor Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/monitor)

It is recommended since the metrics and logs help you to investigate some issues in the production environment when they happen.

#### Enable service endpoint (Recommended in the production environment)

You can configure the Azure Cosmos DB account to allow access only from a specific subnet of a virtual network (VNet). Please refer to the official document for more details.

* [Configure access to Azure Cosmos DB from virtual networks (VNet)](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-vnet-service-endpoint)

It is recommended since the private internal connections not via WAN can make a system more secure.

#### Configure the Request Units (Optional based on your environment)

You can configure the **Request Units** of Cosmos DB based on your requirements. Please refer to the official document for more details on the request units.

* [Request Units in Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/request-units)

You can configure Request Units using ScalarDB/DL Schema Loader when you create a table. Please refer to the following document for more details on how to configure Request Units (RU) using ScalarDB/DL Schema Loader.

* [ScalarDB Schema Loader](https://github.com/scalar-labs/scalardb/blob/master/docs/schema-loader.md)

## Azure Database for MySQL

### Authentication method

When you use Azure Database for MySQL, you must set `JDBC_URL`, `USERNAME`, and `PASSWORD` in the ScalarDB/ScalarDL properties file as follows.

```properties
scalar.db.contact_points=<JDBC_URL>
scalar.db.username=<USERNAME>
scalar.db.password=<PASSWORD>
scalar.db.storage=jdbc
```

Please refer to the following document for more details on the properties for Azure Database for MySQL (JDBC databases).

* [Configure ScalarDB for JDBC databases](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb.md#configure-scalardb-3)

### Required configuration/steps

#### Create a database server

You must create a database server. Please refer to the official document for more details.

* [Quickstart: Use the Azure portal to create an Azure Database for MySQL Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/quickstart-create-server-portal)

You can choose **Single Server** or **Flexible Server** for your deployment. However, Flexible Server is recommended in Azure. This document assumes that you use Flexible Server. Please refer to the official documents for more details on the deployment models.

* [What is Azure Database for MySQL?](https://learn.microsoft.com/en-us/azure/mysql/single-server/overview#deployment-models)

### Optional configurations/steps

#### Configure backup configurations (Optional based on your environment)

Azure Database for MySQL gets a backup by default. You do not need to enable the backup feature manually.

If you want to change some backup configurations like the backup retention period, you can configure it. Please refer to the official document for more details.

* [Backup and restore in Azure Database for MySQL Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-backup-restore)

Please refer to the following document for more details on how to backup/restore the Scalar product data.

* [Backup restore guide for Scalar products](./BackupRestoreGuide.md)

#### Configure monitoring (Recommended in the production environment)

You can configure the monitoring of Azure Database for MySQL using its native feature. Please refer to the official document for more details.

* [Monitor Azure Database for MySQL Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-monitoring)

It is recommended since the metrics and logs help you to investigate some issues in the production environment when they happen.

#### Disable public access (Recommended in the production environment)

You can configure **Private access (VNet Integration)** as a **Connectivity method**. Please refer to the official document for more details.

* [Connectivity and networking concepts for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-networking)

You can access the database server from the Scalar product pods on your AKS cluster as follows.

* Create the database server on the same VNet as your AKS cluster.
* Connect the VNet for the database server and the VNet for the AKS cluster for the Scalar product deployment using [Virtual network peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview). (// TODO: We need to test this feature with Scalar products.)

It is recommended since the private internal connections not via WAN can make a system more secure.

## Azure Database for PostgreSQL

### Authentication method

When you use Azure Database for PostgreSQL, you must set `JDBC_URL`, `USERNAME`, and `PASSWORD` in the ScalarDB/ScalarDL properties file as follows.

```properties
scalar.db.contact_points=<JDBC_URL>
scalar.db.username=<USERNAME>
scalar.db.password=<PASSWORD>
scalar.db.storage=jdbc
```

Please refer to the following document for more details on the properties for Azure Database for PostgreSQL (JDBC databases).

* [Configure ScalarDB for JDBC databases](https://github.com/scalar-labs/scalardb/blob/master/docs/getting-started-with-scalardb.md#configure-scalardb-3)

### Required configuration/steps

#### Create a database server

You must create a database server. Please refer to the official document for more details.

* [Quickstart: Create an Azure Database for PostgreSQL - Flexible Server in the Azure portal](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal)

You can choose **Single Server** or **Flexible Server** for your deployment. However, Flexible Server is recommended in Azure. This document assumes that you use Flexible Server. Please refer to the official documents for more details on the deployment models.

* [What is Azure Database for PostgreSQL?](https://learn.microsoft.com/en-us/azure/postgresql/single-server/overview#deployment-models)

### Optional configurations/steps

#### Configure backup configurations (Optional based on your environment)

Azure Database for PostgreSQL gets a backup by default. You do not need to enable the backup feature manually.

If you want to change some backup configurations like the backup retention period, you can configure it. Please refer to the official document for more details.

* [Backup and restore in Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-backup-restore)

Please refer to the following document for more details on how to backup/restore the Scalar product data.

* [Backup restore guide for Scalar products](./BackupRestoreGuide.md)

#### Configure monitoring (Recommended in the production environment)

You can configure the monitoring of Azure Database for PostgreSQL using its native feature. Please refer to the official document for more details.

* [Monitor metrics on Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-monitoring)

It is recommended since the metrics and logs help you to investigate some issues in the production environment when they happen.

#### Disable public access (Recommended in the production environment)

You can configure **Private access (VNet Integration)** as a **Connectivity method**. Please refer to the official document for more details.

* [Networking overview for Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking)

You can access the database server from the Scalar product pods on your AKS cluster as follows.

* Create the database server on the same VNet as your AKS cluster.
* Connect the VNet for the database server and the VNet for the AKS cluster for the Scalar product deployment using [Virtual network peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview). (// TODO: We need to test this feature with Scalar products.)

It is recommended since the private internal connections not via WAN can make a system more secure.
