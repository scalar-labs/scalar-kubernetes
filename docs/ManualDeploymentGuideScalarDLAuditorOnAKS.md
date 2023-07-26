# Deploy ScalarDL Ledger and ScalarDL Auditor on Azure Kubernetes Service (AKS)

This guide explains how to deploy ScalarDL Ledger and ScalarDL Auditor on Azure Kubernetes Service (AKS).

In this guide, you will create one of the following three environments in your Azure environment. To make Byzantine fault detection work properly, we recommend deploying ScalarDL Ledger and ScalarDL Auditor on different administrative domains (i.e., separate environments).

* Use different Azure accounts (most recommended way)

  ![image](./images/png/AKS_ScalarDL_Auditor_Multi_Account.drawio.png)

* Use different Azure Virtual Networks (VNets) (second recommended way)

  ![image](./images/png/AKS_ScalarDL_Auditor_Multi_VNet.drawio.png)

* Use different namespaces (third recommended way)

  ![image](./images/png/AKS_ScalarDL_Auditor_Multi_Namespace.drawio.png)

**Note:** This guide follows the second recommended way, "Use different VNets."

## Step 1. Subscribe to ScalarDL Ledger and ScalarDL Auditor in Azure Marketplace

You must get the ScalarDL Ledger and ScalarDL Auditor container images by visiting [Azure Marketplace](https://azuremarketplace.microsoft.com/en/marketplace/apps/scalarinc.scalardl) and subscribing to ScalarDL Ledger and ScalarDL Auditor. For details on how to subscribe to ScalarDL Ledger and ScalarDL Auditor in Azure Marketplace, see [Get Scalar products from Microsoft Azure Marketplace](./AzureMarketplaceGuide.md#get-scalar-products-from-microsoft-azure-marketplace).

## Step 2. Create an AKS cluster for ScalarDL Ledger

You must create an AKS cluster for the ScalarDL Ledger deployment. For details, see [Guidelines for creating an AKS cluster for Scalar products](./CreateAKSClusterForScalarProducts.md).

## Step 3. Create an AKS cluster for ScalarDL Auditor

You must also create an AKS cluster for the ScalarDL Auditor deployment. For details, see [Guidelines for creating an AKS cluster for Scalar products](./CreateAKSClusterForScalarProducts.md).

## Step 4. Set up a database for ScalarDL Ledger

You must prepare a database before deploying ScalarDL Ledger. Because ScalarDL Ledger uses ScalarDB internally to access databases, refer to [ScalarDB Supported Databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md) to see which types of databases ScalarDB supports.

For details on setting up a database, see [Set up a database for ScalarDB/ScalarDL deployment in Azure](./SetupDatabaseForAzure.md).

## Step 5. Set up a database for ScalarDL Auditor

You must also prepare a database before deploying ScalarDL Auditor. Because ScalarDL Auditor uses ScalarDB internally to access databases, refer to [ScalarDB Supported Databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md) to see which types of databases ScalarDB supports.

For details on setting up a database, see [Set up a database for ScalarDB/ScalarDL deployment in Azure](./SetupDatabaseForAzure.md).

## Step 6. Create a bastion server for ScalarDL Ledger

To execute some tools for deploying and managing ScalarDL Ledger on AKS, you must prepare a bastion server in the same VNet of the AKS cluster that you created in **Step 2**. For details, see [Create a Bastion Server](./CreateBastionServer.md).

## Step 7. Create a bastion server for ScalarDL Auditor

To execute some tools for deploying and managing ScalarDL Auditor on AKS, you must prepare a bastion server in the same VNet of the AKS cluster that you created in **Step 3**. For details, see [Create a Bastion Server](./CreateBastionServer.md).

## Step 8. Create network peering between two AKS clusters

To make ScalarDL work properly, ScalarDL Ledger and ScalarDL Auditor need to connect to each other. You must connect two VNets by using [virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview). For details, see [Configure Network Peering for ScalarDL Auditor Mode](./NetworkPeeringForScalarDLAuditor.md).

## Step 9. Prepare custom values files for the Scalar Helm Charts for both ScalarDL Ledger and ScalarDL Schema Loader

To perform tasks, like accessing information in the database that you created in **Step 4**, you must configure custom values files for the Scalar Helm Charts for both ScalarDL Ledger and ScalarDL Schema Loader (for Ledger) based on your environment. For details, see [Configure a custom values file for Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-file.md).

## Step 10. Deploy ScalarDL Ledger by using the Scalar Helm Chart

Deploy ScalarDL Ledger on your AKS cluster by using the Helm Chart for ScalarDL Ledger. For details, see [Deploy Scalar products using Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalar-products.md).

**Note:** We recommend creating a dedicated namespace by using the `kubectl create ns scalardl-ledger` command and deploying ScalarDL Ledger in the namespace by using the `-n scalardl-ledger` option with the `helm install` command.

## Step 11. Prepare custom values files for the Scalar Helm Charts for both ScalarDL Auditor and ScalarDL Schema Loader

To perform tasks, like accessing information in the database that you created in **Step 5**, you must also configure a custom values files for the Scalar Helm Chart for both ScalarDL Auditor and ScalarDL Schema Loader (for Auditor) based on your environment. For details, see [Configure a custom values file for Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-file.md).

## Step 12. Deploy ScalarDL Auditor by using the Scalar Helm Chart

Deploy ScalarDL Auditor on your AKS cluster by using the Helm Chart for ScalarDL Auditor. For details, see [Deploy Scalar products using Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalar-products.md).

**Note:** We recommend creating a dedicated namespace by using the `kubectl create ns scalardl-auditor` command and deploying ScalarDL Auditor in the namespace by using the `-n scalardl-auditor` option with the `helm install` command.

## Step 13. Check the status of your ScalarDL Ledger deployment

After deploying ScalarDL Ledger in your AKS cluster, you must check the status of each component. For details, see [Components to Regularly Check When Running in a Kubernetes Environment](./RegularCheck.md).

## Step 14. Check the status of your ScalarDL Auditor deployment

After deploying ScalarDL Auditor in your AKS cluster, you must check the status of each component. For details, see [Components to Regularly Check When Running in a Kubernetes Environment](./RegularCheck.md).

## Step 15. Monitor your ScalarDL Ledger deployment

After deploying ScalarDL Ledger in your AKS cluster, we recommend monitoring the deployed components and collecting their logs, especially in production. For details, see [Monitoring Scalar products on a Kubernetes cluster](./K8sMonitorGuide.md) and [Collecting logs from Scalar products on a Kubernetes cluster](./K8sLogCollectionGuide.md).

## Step 16. Monitor your ScalarDL Auditor deployment

After deploying ScalarDL Auditor in your AKS cluster, we recommend monitoring the deployed components and collecting their logs, especially in production. For details, see [Monitoring Scalar products on a Kubernetes cluster](./K8sMonitorGuide.md) and [Collecting logs from Scalar products on a Kubernetes cluster](./K8sLogCollectionGuide.md).

## Remove ScalarDL Ledger and ScalarDL Auditor from AKS

If you want to remove the environment that you created, please remove all the resources in reverse order from which you created them in.
