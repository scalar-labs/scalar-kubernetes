# Deploy ScalarDL Ledger on AKS (Azure Kubernetes Service)

ScalarDL is scalable and practical Byzantine fault detection middleware for transactional database systems, which achieves correctness, scalability, and database agnosticism.

ScalarDL is composed of [Ledger](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started.md), [Auditor](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started-auditor.md), and [Client SDK](https://github.com/scalar-labs/scalardl/tree/master/docs#client-sdks). ScalarDL Ledger manages application data in its own unique way using hash-chain and digital signature. ScalarDL Auditor is an optional component and manages a copy of Ledger data without depending on Ledger to identify the discrepancy between Ledger and Auditor data. The Client SDK is a set of user-facing programs to interact with Ledger and Auditor.

We can deploy **ScalarDL Ledger** on any Kubernetes services. This document explains how to deploy **ScalarDL Ledger** on AKS.

## What we create

In this guide, we create the following environment on your Azure account.

![image](./images/png/AKS_ScalarDL_Ledger.drawio.png)

## Step 1. Subscribe to ScalarDL Ledger in Azure Marketplace

You can get the ScalarDL Ledger container image from [Azure Marketplace](https://azuremarketplace.microsoft.com/en/marketplace/apps/scalarinc.scalardl). First, you need to subscribe to it. For more details on how to subscribe to ScalarDL Ledger in Azure Marketplace, see [Get Scalar products from Microsoft Azure Marketplace - How to install Scalar products through Azure Marketplace](./AzureMarketplaceGuide.md#get-scalar-products-from-microsoft-azure-marketplace).

## Step 2. Create an AKS cluster

Create an AKS cluster for the deployment of ScalarDL Ledger. See [Create an AKS cluster for Scalar products](./CreateAKSClusterForScalarProducts.md) for more details.

## Step 3. Set up a database for ScalarDL Ledger

ScalarDL Ledger uses ScalarDB in its internal to access a database and ScalarDB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy ScalarDL Ledger. See [Set up a database for ScalarDB/ScalarDL deployment in Azure](./SetupDatabaseForAzure.md) for more details.

## Step 4. Create a bastion server

For executing some tools to deploy and manage ScalarDL Ledger on AKS, you need to prepare a bastion server in the same VNet of the AKS cluster you created in **Step 2**. See [Create a bastion server](./CreateBastionServer.md) for more details.

## Step 5. Prepare a custom values file of Helm 

You need to configure a custom values file for the Helm Chart of ScalarDL Ledger and ScalarDL Schema Loader based on your environment (e.g., access information of the database you created in **Step 3**). See [Configure a custom values file for Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-file.md) for more details.

## Step 6. Deploy ScalarDL Ledger using Scalar Helm Chart

Deploy ScalarDL Ledger on your AKS cluster using Scalar Helm Chart. See [Deploy Scalar products using Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalar-products.md) for more details.

Note: We recommend creating a dedicated namespace by using the `kubectl create ns scalardl-ledger` command and deploying ScalarDL Ledger in the namespace by using the `-n scalardl-ledger` option with the `helm install` command.

## Step 7. Check the status of ScalarDL Ledger deployment

After deploying ScalarDL Ledger on your AKS cluster, you need to check the status of each component. See [What you might want to check on a regular basis](./RegularCheck.md) for more details.

## Step 8. Monitoring for ScalarDL Ledger deployment

After deploying ScalarDL Ledger on your AKS cluster, we recommend monitoring the deployed components and collecting their logs, especially in production. See [Monitoring Scalar products on a Kubernetes cluster](./K8sMonitorGuide.md) and [Collecting logs from Scalar products on a Kubernetes cluster](./K8sLogCollectionGuide.md) for more details.

---

## Uninstall ScalarDL Ledger on AKS

If you want to uninstall the environment you created, please uninstall/remove resources in the reverse order of creation.
