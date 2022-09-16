# Deploy Scalar DB Server on AKS

Scalar DB Server is a gRPC server that implements Scalar DB interface. With Scalar DB Server, you can use Scalar DB features from multiple programming languages that are supported by gRPC.  

We can deploy Scalar DB Server on any Kubernetes services. This document explains how to deploy Scalar DB Server on AKS.  

## What we create

In this guide, we create the following environment on your Azure account.  

![image](images/scalardbserver-aks-diagram.png)

// TODO: Update the figure based on the latest document

## Step 1. Subscribe to Scalar DB Server in Azure Marketplace

You can get the Scalar DB Server container image from [Azure Marketplace](https://azuremarketplace.microsoft.com/en/marketplace/apps/scalarinc.scalardb). First, you need to subscribe to it. Please refer to the following document to subscribe to Scalar DB Server in Azure Marketplace.  

* [How to install Scalar products through Azure Marketplace](./AzureMarketplaceGuide.md)

Note: Please see the **Get Scalar products from Microsoft Azure Marketplace** section in the above document.  

## Step 2. Set up a database for Scalar DB Server

Scalar DB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy Scalar DB Server.  

Please refer to the following document for more details.  

* [Set up a database for Scalar DB/Scalar DL deployment in Azure](./SetupDatabaseForAzure.md) // TODO: Update existing document

## Step 3. Create AKS Cluster

Create AKS Cluster for the deployment of Scalar DB Server. Please refer to the following document for more details.  

* [Create AKS Cluster for Scalar Products]() // TODO: Create a new document

## Step 4. Create bastion server

For executing some tools to deploy and manage Scalar DB Server on AKS, you need to prepare a bastion server in the same VNet of the AKS Cluster you created in **Step 3**. Please refer to the following document for more details.  

* [Create bastion server]() // TODO: Create a new document

## Step 5. Prepare custom values file of Helm

You need to configure your custom values file for Helm Chart of Scalar DB Server based on your environment (e.g., access information of the database you created in **Step 2**). Please refer to the following document for more details.  

* [Configure custom values file of Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 6. Deploy Scalar DB Server using Scalar Helm Chart

Deploy Scalar DB Server on your AKS Cluster using Scalar Helm Chart. Please refer to the following document for more details.  

* [Deploy Scalar Products using Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 7. Check the status of Scalar DB Server deployment

After deploying Scalar DB Server on your AKS Cluster, you need to check the status of each component. Please refer to the following document for more details.  

* [What you might want to check on a regular basis](./RegularCheck.md) // TODO: Update existing document

## Step 8. Monitoring for Scalar DB Server deployment

After deploying Scalar DB Server on your AKS Cluster, you need to monitor each component and collect logs. Please refer to the following document for more details.  

* [Kubernetes Monitor Guide](./K8sMonitorGuide.md) // TODO: Update existing document
* [How to collect logs from Kubernetes applications](./K8sLogCollectionGuide.md) // TODO: Update existing document

---

## Uninstall Scalar DB Server on AKS

If you want to uninstall the environment you created in the above steps, please uninstall/remove resources in the reverse order of creation.  // TODO: Add delete steps in each document
