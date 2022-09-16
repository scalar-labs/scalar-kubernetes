# Deploy Scalar DL Ledger and Scalar DL Auditor on AKS

Scalar DL is scalable and practical Byzantine fault detection middleware for transactional database systems, which achieves correctness, scalability, and database agnosticism.  

Scalar DL is composed of [Ledger](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started.md), [Auditor](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started-auditor.md), and [Client SDK](https://github.com/scalar-labs/scalardl/tree/master/docs#client-sdks). Scalar DL Ledger manages application data in its own unique way using hash-chain and digital signature. Scalar DL Auditor is an optional component and manages a copy of Ledger data without depending on Ledger to identify the discrepancy between Ledger and Auditor data. The Client SDK is a set of user-facing programs to interact with Ledger and Auditor.  

We can deploy **Scalar DL Ledger** and **Scalar DL Auditor** on any Kubernetes services. This document explains how to deploy **Scalar DL Ledger** and **Scalar DL Auditor** on AKS.  

## What we create

In this guide, we create the following environment on your Azure account.  

![image](images/auditor-arch.png)

// TODO: Update the figure based on the latest document

## Step 1. Subscribe to Scalar DL Ledger and Scalar DL Auditor in Azure Marketplace

You can get the container images of Scalar DL Ledger and Scalar DL Auditor from [Azure Marketplace](https://azuremarketplace.microsoft.com/en/marketplace/apps/scalarinc.scalardl).  

First, you need to subscribe to them. Please refer to the following document to subscribe to Scalar DL Ledger and Scalar DL Auditor in Azure Marketplace.  

* [How to install Scalar products through Azure Marketplace](./AzureMarketplaceGuide.md)

Note: Please see the **Get Scalar products from Microsoft Azure Marketplace** section in the above document.  

## Step 2. Set up a database for Scalar DL Ledger

Scalar DL Ledger uses Scalar DB in its internal to access a database and Scalar DB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy Scalar DL Ledger.  

Please refer to the following document for more details.  

* [Set up a database for Scalar DB/Scalar DL deployment in Azure](./SetupDatabaseForAzure.md) // TODO: Update existing document

## Step 3. Set up a database for Scalar DL Auditor

Scalar DL Auditor uses Scalar DB in its internal to access a database and Scalar DB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy Scalar DL Auditor.  

Please refer to the following document for more details.  

* [Set up a database for Scalar DB/Scalar DL deployment in Azure](./SetupDatabaseForAzure.md) // TODO: Update existing document

## Step 4. Create AKS Clusters for Scalar DL Ledger

Create AKS Clusters for the deployment of Scalar DL Ledger. Please refer to the following document for more details.  

* [Create AKS Cluster for Scalar Products]() // TODO: Create a new document

## Step 5. Create AKS Clusters for Scalar DL Auditor

Create AKS Clusters for the deployment of Scalar DL Auditor. Please refer to the following document for more details.  

* [Create AKS Cluster for Scalar Products]() // TODO: Create a new document

## Step 6. Create bastion server for Scalar DL Ledger

For executing some tools to deploy and manage Scalar DL Ledger on AKS, you need to prepare a bastion server in the same VNet of the AKS Cluster you created in **Step 4**. Please refer to the following document for more details.  

* [Create bastion server]() // TODO: Create a new document

## Step 7. Create bastion server for Scalar DL Auditor

For executing some tools to deploy and manage Scalar DL Auditor on AKS, you need to prepare a bastion server in the same VNet of the AKS Cluster you created in **Step 5**. Please refer to the following document for more details.  

* [Create bastion server]() // TODO: Create a new document

## Step 8. Create network peering between two AKS Clusters

To make Scalar DL work properly, Scalar DL Ledger and Scalar DL Auditor need to connect with each other. So, you need to connect two VNets using [Virtual Network Peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview). Please refer to the following document for more details.  

* [Create network peering for Scalar DL Auditor mode]() // TODO: Create a new document

## Step 9. Prepare custom values file of Helm Chart of Scalar DL Ledger

You need to configure your custom values file for Helm Chart of Scalar DL Ledger and Scalar DL Schema Loader (for Ledger) based on your environment (e.g., access information of the database you created in **Step 2**). Please refer to the following document for more details.  

## Step 10. Deploy Scalar DL Ledger using Scalar Helm Chart

Deploy Scalar DL Ledger on your AKS Cluster using Scalar Helm Chart. Please refer to the following document for more details.  

* [Deploy Scalar Products using Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 11. Prepare custom values file of Helm Chart of Scalar DL Auditor

You need to configure your custom values file for Helm Chart of Scalar DL Auditor and Scalar DL Schema Loader (for Auditor) based on your environment (e.g., access information of the database you created in **Step 3**). Please refer to the following document for more details.  

* [Configure custom values file of Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 12. Deploy Scalar DL Auditor using Scalar Helm Chart

Deploy Scalar DL Auditor on your AKS Cluster using Scalar Helm Chart. Please refer to the following document for more details.  

* [Deploy Scalar Products using Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 13. Check the status of Scalar DL Ledger deployment

After deploying Scalar DL Ledger on your AKS Cluster, you need to check the status of each component. Please refer to the following document for more details.  

* [What you might want to check on a regular basis](./RegularCheck.md) // TODO: Update existing document

## Step 14. Check the status of Scalar DL Auditor deployment

After deploying Scalar DL Auditor on your AKS Cluster, you need to check the status of each component. Please refer to the following document for more details.  

* [What you might want to check on a regular basis](./RegularCheck.md) // TODO: Update existing document

## Step 15. Monitoring for Scalar DL Ledger deployment

After deploying Scalar DL Ledger on your AKS Cluster, you need to monitor each component and collect logs. Please refer to the following document for more details.  

* [Kubernetes Monitor Guide](./K8sMonitorGuide.md) // TODO: Update existing document
* [How to collect logs from Kubernetes applications](./K8sLogCollectionGuide.md) // TODO: Update existing document

## Step 16. Monitoring for Scalar DL Auditor deployment

After deploying Scalar DL Auditor on your AKS Cluster, you need to monitor each component and collect logs. Please refer to the following document for more details.  

* [Kubernetes Monitor Guide](./K8sMonitorGuide.md) // TODO: Update existing document
* [How to collect logs from Kubernetes applications](./K8sLogCollectionGuide.md) // TODO: Update existing document

---

## Uninstall Scalar DL Ledger and Scalar DL Auditor on AKS

If you want to uninstall the environment you created in the above steps, please uninstall/remove resources in the reverse order of creation.  // TODO: Add delete steps in each document
