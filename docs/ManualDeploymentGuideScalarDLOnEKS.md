# Deploy ScalarDL Ledger on Amazon EKS (Amazon Elastic Kubernetes Service)

ScalarDL is scalable and practical Byzantine fault detection middleware for transactional database systems, which achieves correctness, scalability, and database agnosticism.  

ScalarDL is composed of [Ledger](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started.md), [Auditor](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started-auditor.md), and [Client SDK](https://github.com/scalar-labs/scalardl/tree/master/docs#client-sdks). ScalarDL Ledger manages application data in its own unique way using hash-chain and digital signature. ScalarDL Auditor is an optional component and manages a copy of Ledger data without depending on Ledger to identify the discrepancy between Ledger and Auditor data. The Client SDK is a set of user-facing programs to interact with Ledger and Auditor.  

We can deploy **ScalarDL Ledger** on any Kubernetes services. This document explains how to deploy **ScalarDL Ledger** on EKS.  

## What we create

In this guide, we create the following environment on your AWS account.  

![image](images/network_diagram_eks.png)

// TODO: Update the figure based on the latest document

## Step 1. Subscribe to ScalarDL Ledger in AWS Marketplace

You can get the ScalarDL Ledger container image from [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-3jdwfmqonx7a2). First, you need to subscribe to it. Please refer to the following document to subscribe to ScalarDL Ledger in AWS Marketplace.  

* [How to install Scalar products through AWS Marketplace](./AwsMarketplaceGuide.md)

Note: Please see the **Subscribe to Scalar products from AWS Marketplace** section in the above document.  

## Step 2. Set up a database for ScalarDL Ledger

ScalarDL Ledger uses ScalarDB in its internal to access a database and ScalarDB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy ScalarDL Ledger.  

Please refer to the following document for more details.  

* [Set up a database for ScalarDB/ScalarDL deployment on AWS](./SetupDatabaseForAWS.md)

## Step 3. Create an EKS cluster

Create an EKS cluster for the deployment of ScalarDL Ledger. Please refer to the following document for more details.  

* [Create an EKS cluster for Scalar Products]() // TODO: Create a new document

## Step 4. Create a bastion server

For executing some tools to deploy and manage ScalarDL Ledger on EKS, you need to prepare a bastion server in the same VPC of the EKS cluster you created in **Step 3**. Please refer to the following document for more details.  

* [Create a bastion server]() // TODO: Create a new document

## Step 5. Prepare a custom values file of Helm 

You need to configure a custom values file for the Helm Chart of ScalarDL Ledger and ScalarDL Schema Loader based on your environment (e.g., access information of the database you created in **Step 2**). Please refer to the following document for more details.  

* [Configure a custom values file of Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 6. Deploy ScalarDL Ledger using Scalar Helm Chart

Deploy ScalarDL Ledger on your EKS cluster using Scalar Helm Chart. Please refer to the following document for more details.  

* [Deploy Scalar Products using Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 7. Check the status of ScalarDL Ledger deployment

After deploying ScalarDL Ledger on your EKS cluster, you need to check the status of each component. Please refer to the following document for more details.  

* [What you might want to check on a regular basis](./RegularCheck.md) // TODO: Update existing document

## Step 8. Monitoring for ScalarDL Ledger deployment

After deploying ScalarDL Ledger on your EKS cluster, it is recommended to monitor the deployed components and collect their logs, especially in production. Please refer to the following document for more details.  

* [Kubernetes Monitor Guide](./K8sMonitorGuide.md) // TODO: Update existing document
* [How to collect logs from Kubernetes applications](./K8sLogCollectionGuide.md) // TODO: Update existing document

---

## Uninstall ScalarDL Ledger on EKS

If you want to uninstall the environment you created, please uninstall/remove resources in the reverse order of creation.  // TODO: Add delete steps in each document
