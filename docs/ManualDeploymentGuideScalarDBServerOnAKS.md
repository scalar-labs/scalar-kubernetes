# Deploy ScalarDB Server on AKS (Azure Kubernetes Service)

ScalarDB Server is a gRPC server that implements the ScalarDB interface. With ScalarDB Server, you can use ScalarDB features from multiple programming languages that are supported by gRPC.  

We can deploy ScalarDB Server on any Kubernetes services. This document explains how to deploy ScalarDB Server on AKS.  

## What we create

In this guide, we create the following environment on your Azure account.  

![image](images/scalardbserver-aks-diagram.png)

// TODO: Update the figure based on the latest document

## Step 1. Subscribe to ScalarDB Server in Azure Marketplace

You can get the ScalarDB Server container image from [Azure Marketplace](https://azuremarketplace.microsoft.com/en/marketplace/apps/scalarinc.scalardb). First, you need to subscribe to it. Please refer to the following document to subscribe to ScalarDB Server in Azure Marketplace.  

* [How to install Scalar products through Azure Marketplace](./AzureMarketplaceGuide.md)

Note: Please see the **Get Scalar products from Microsoft Azure Marketplace** section in the above document.  

## Step 2. Set up a database for ScalarDB Server

ScalarDB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy ScalarDB Server.  

Please refer to the following document for more details.  

* [Set up a database for ScalarDB/ScalarDL deployment in Azure](./SetupDatabaseForAzure.md) // TODO: Update existing document

## Step 3. Create an AKS cluster

Create an AKS cluster for the deployment of ScalarDB Server. Please refer to the following document for more details.  

* [Create an AKS cluster for Scalar Products]() // TODO: Create a new document

## Step 4. Create a bastion server

For executing some tools to deploy and manage ScalarDB Server on AKS, you need to prepare a bastion server in the same VNet of the AKS cluster you created in **Step 3**. Please refer to the following document for more details.  

* [Create a bastion server]() // TODO: Create a new document

## Step 5. Prepare a custom values file of Helm

You need to configure a custom values file for the Helm Chart of ScalarDB Server based on your environment (e.g., access information of the database you created in **Step 2**). Please refer to the following document for more details.  

* [Configure a custom values file of Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 6. Deploy ScalarDB Server using Scalar Helm Chart

Deploy ScalarDB Server on your AKS cluster using Scalar Helm Chart. Please refer to the following document for more details.  

* [Deploy Scalar Products using Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 7. Check the status of ScalarDB Server deployment

After deploying ScalarDB Server on your AKS cluster, you need to check the status of each component. Please refer to the following document for more details.  

* [What you might want to check on a regular basis](./RegularCheck.md) // TODO: Update existing document

## Step 8. Monitoring for ScalarDB Server deployment

After deploying ScalarDB Server on your AKS cluster, it is recommended to monitor the deployed components and collect their logs, especially in production. Please refer to the following document for more details.  

* [Kubernetes Monitor Guide](./K8sMonitorGuide.md) // TODO: Update existing document
* [How to collect logs from Kubernetes applications](./K8sLogCollectionGuide.md) // TODO: Update existing document

---

## Uninstall ScalarDB Server on AKS

If you want to uninstall the environment you created, please uninstall/remove resources in the reverse order of creation.  // TODO: Add delete steps in each document
