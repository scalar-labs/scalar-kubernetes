# Deploy ScalarDB Server on Amazon Elastic Kubernetes Service (EKS)

This guide explains how to deploy ScalarDB Server on Amazon Elastic Kubernetes Service (EKS).

In this guide, you will create one of the following two environments in your AWS environment. The difference between the two environments is how you plan to deploy the application:

* Deploy your application in the same EKS cluster as your ScalarDB Server deployment. In this case, you don't need to use the load balancers that AWS provides to access Scalar Envoy from your application.

  ![image](./images/png/EKS_ScalarDB_Server_App_In_Cluster.drawio.png)  

* Deploy your application in an environment that is different from the EKS cluster that contains your ScalarDB Server deployment. In this case, you must use the load balancers that AWS provides to access Scalar Envoy from your application.

  ![image](./images/png/EKS_ScalarDB_Server_App_Out_Cluster.drawio.png)  

## Step 1. Subscribe to ScalarDB Server in AWS Marketplace

You must get the ScalarDB Server container image by visiting [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-rzbuhxgvqf4d2) and subscribing to ScalarDB Server. For details on how to subscribe to ScalarDB Server in AWS Marketplace, see [Subscribe to Scalar products from AWS Marketplace](./AwsMarketplaceGuide.md#subscribe-to-scalar-products-from-aws-marketplace).

## Step 2. Create an EKS cluster

You must create an EKS cluster for the ScalarDB Server deployment. For details, see [Guidelines for creating an Amazon EKS cluster for Scalar products](./CreateEKSClusterForScalarProducts.md).

## Step 3. Set up a database for ScalarDB Server

You must prepare a database before deploying ScalarDB Server. To see which types of databases ScalarDB supports, refer to [ScalarDB Supported Databases](https://github.com/scalar-labs/scalardb/blob/master/docs/scalardb-supported-databases.md).

For details on setting up a database, see [Set up a database for ScalarDB/ScalarDL deployment on AWS](./SetupDatabaseForAWS.md).

## Step 4. Create a bastion server

To execute some tools for deploying and managing ScalarDB Server on EKS, you must prepare a bastion server in the same Amazon Virtual Private Cloud (VPC) of the EKS cluster that you created in **Step 2**. For details, see [Create a Bastion Server](./CreateBastionServer.md).

## Step 5. Prepare a custom values file for the Scalar Helm Chart

To perform tasks, like accessing information in the database that you created in **Step 3**, you must configure a custom values file for the Scalar Helm Chart for ScalarDB Server based on your environment. For details, see [Configure a custom values file for Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-file.md).

**Note:** If you deploy your application in an environment that is different from the EKS cluster that has your ScalarDB Server deployment, you must set the `envoy.service.type` parameter to `LoadBalancer` to access Scalar Envoy from your application.

## Step 6. Deploy ScalarDB Server by using the Scalar Helm Chart

Deploy ScalarDB Server on your EKS cluster by using the Helm Chart for ScalarDB Server. For details, see [Deploy Scalar products using Scalar Helm Charts](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalar-products.md).

**Note:** We recommend creating a dedicated namespace by using the `kubectl create ns scalardb` command and deploying ScalarDB Server in the namespace by using the `-n scalardb` option with the `helm install` command.

## Step 7. Check the status of your ScalarDB Server deployment

After deploying ScalarDB Server in your EKS cluster, you must check the status of each component. For details, see [Components to Regularly Check When Running in a Kubernetes Environment](./RegularCheck.md).

## Step 8. Monitor your ScalarDB Server deployment

After deploying ScalarDB Server in your EKS cluster, we recommend monitoring the deployed components and collecting their logs, especially in production. For details, see [Monitoring Scalar products on a Kubernetes cluster](./K8sMonitorGuide.md) and [Collecting logs from Scalar products on a Kubernetes cluster](./K8sLogCollectionGuide.md).

## Remove ScalarDB Server from EKS

If you want to remove the environment that you created, please remove all the resources in reverse order from which you created them in.
