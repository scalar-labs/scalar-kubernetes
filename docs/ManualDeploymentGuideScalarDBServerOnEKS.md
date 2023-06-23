# Deploy ScalarDB Server on Amazon EKS (Amazon Elastic Kubernetes Service)

ScalarDB Server is a gRPC server that implements the ScalarDB interface. With ScalarDB Server, you can use ScalarDB features from multiple programming languages that are supported by gRPC.  

We can deploy ScalarDB Server on any Kubernetes services. This document explains how to deploy ScalarDB Server on EKS.  

## What we create

In this guide, we create the following environment on your AWS account.  

![image](images/scalardbserver-eks-diagram.png)

// TODO: Update the figure based on the latest document

## Step 1. Subscribe to ScalarDB Server in AWS Marketplace

You can get the ScalarDB Server container image from [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-rzbuhxgvqf4d2). First, you need to subscribe to it. Please refer to the following document to subscribe to ScalarDB Server in AWS Marketplace.  

* [How to install Scalar products through AWS Marketplace](./AwsMarketplaceGuide.md)

Note: Please see the **Subscribe to Scalar products from AWS Marketplace** section in the above document.  

## Step 2. Set up a database for ScalarDB Server

ScalarDB supports [several databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md). You need to prepare a database before you deploy ScalarDB Server.  

Please refer to the following document for more details.  

* [Set up a database for ScalarDB/ScalarDL deployment on AWS](./SetupDatabaseForAWS.md) // TODO: Update existing document

## Step 3. Create an EKS cluster

Create an EKS cluster for the deployment of ScalarDB Server. Please refer to the following document for more details.  

* [Create an EKS cluster for Scalar Products]() // TODO: Create a new document

## Step 4. Create a bastion server

For executing some tools to deploy and manage ScalarDB Server on EKS, you need to prepare a bastion server in the same VPC of the EKS cluster you created in **Step 3**. Please refer to the following document for more details.  

* [Create a bastion server]() // TODO: Create a new document

## Step 5. Prepare a custom values file of Helm

You need to configure a custom values file for the Helm Chart of ScalarDB Server based on your environment (e.g., access information of the database you created in **Step 2**). Please refer to the following document for more details.  

* [Configure a custom values file of Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 6. Deploy ScalarDB Server using Scalar Helm Chart

Deploy ScalarDB Server on your EKS cluster using Scalar Helm Chart. Please refer to the following document for more details.  

* [Deploy Scalar Products using Scalar Helm Chart]() // TODO: Create a new document in the Scalar Helm Chart repository

## Step 7. Check the status of ScalarDB Server deployment

After deploying ScalarDB Server on your EKS cluster, you need to check the status of each component. Please refer to the following document for more details.  

* [What you might want to check on a regular basis](./RegularCheck.md) // TODO: Update existing document

## Step 8. Monitoring for ScalarDB Server deployment

After deploying ScalarDB Server on your EKS cluster, it is recommended to monitor the deployed components and collect their logs, especially in production. Please refer to the following document for more details.  

* [Kubernetes Monitor Guide](./K8sMonitorGuide.md) // TODO: Update existing document
* [How to collect logs from Kubernetes applications](./K8sLogCollectionGuide.md) // TODO: Update existing document

---

## Uninstall ScalarDB Server on EKS

If you want to uninstall the environment you created, please uninstall/remove resources in the reverse order of creation.  // TODO: Add delete steps in each document
