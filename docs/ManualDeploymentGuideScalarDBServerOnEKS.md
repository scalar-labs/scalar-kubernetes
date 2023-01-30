# Deploy Scalar DB Server on Amazon EKS (Amazon Elastic Kubernetes Service)

Scalar DB Server is a gRPC server that implements the Scalar DB interface. With Scalar DB Server, you can use Scalar DB features from multiple programming languages that are supported by gRPC.  

We can deploy Scalar DB Server on any Kubernetes services. This document explains how to deploy Scalar DB Server on EKS.  

## What we create

In this guide, we create the following environment on your AWS account.  

![image](images/scalardbserver-eks-diagram.png)

// TODO: Update the figure based on the latest document

## Step 1. Subscribe to Scalar DB Server in AWS Marketplace

You can get the Scalar DB Server container image from [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-rzbuhxgvqf4d2). First, you need to subscribe to it. Please refer to the following document to subscribe to Scalar DB Server in AWS Marketplace.  

* [How to install Scalar products through AWS Marketplace](./AwsMarketplaceGuide.md)

Note: Please see the **Subscribe to Scalar products from AWS Marketplace** section in the above document.  

## Step 2. Set up a database for Scalar DB Server

Scalar DB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy Scalar DB Server.  

Please refer to the following document for more details.  

* [Set up a database for Scalar DB/Scalar DL deployment on AWS](./SetupDatabaseForAWS.md) // TODO: Update existing document

## Step 3. Create an EKS cluster

Create an EKS cluster for the deployment of Scalar DB Server. Please refer to the following document for more details.  

* [Create an EKS cluster for Scalar Products]() // TODO: Create a new document

## Step 4. Create a bastion server

For executing some tools to deploy and manage Scalar DB Server on EKS, you need to prepare a bastion server in the same VPC of the EKS cluster you created in **Step 3**. Please refer to the following document for more details.  

* [Create a bastion server]() // TODO: Create a new document

## Step 5. Prepare a custom values file of Helm

You need to configure a custom values file for the Helm Chart of Scalar DB Server based on your environment (e.g., access information of the database you created in **Step 2**). Please refer to the following document for more details.  

* [Configure a custom values file of Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 6. Deploy Scalar DB Server using Scalar Helm Chart

Deploy Scalar DB Server on your EKS cluster using Scalar Helm Chart. Please refer to the following document for more details.  

* [Deploy Scalar Products using Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 7. Check the status of Scalar DB Server deployment

After deploying Scalar DB Server on your EKS cluster, you need to check the status of each component. Please refer to the following document for more details.  

* [What you might want to check on a regular basis](./RegularCheck.md) // TODO: Update existing document

## Step 8. Monitoring for Scalar DB Server deployment

After deploying Scalar DB Server on your EKS cluster, it is recommended to monitor the deployed components and collect their logs, especially in production. Please refer to the following document for more details.  

* [Kubernetes Monitor Guide](./K8sMonitorGuide.md) // TODO: Update existing document
* [How to collect logs from Kubernetes applications](./K8sLogCollectionGuide.md) // TODO: Update existing document

---

## Uninstall Scalar DB Server on EKS

If you want to uninstall the environment you created, please uninstall/remove resources in the reverse order of creation.  // TODO: Add delete steps in each document