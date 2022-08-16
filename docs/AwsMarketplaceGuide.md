# How to install Scalar products through AWS Marketplace

Scalar products (Scalar DB, Scalar DL, and their tools) are provided in AWS Marketplace as Container Image. This guide explains how to install Scalar products through AWS Marketplace.

Note that some Scalar products are licensed under commercial licenses, and the AWS Marketplace provides them as BYOL (Bring Your Own License). Please make sure you have appropriate licenses.

## Subscribe to Scalar products from AWS Marketplace

1. Access to the AWS Marketplace.
   * [Scalar DB (BYOL)]() // TODO: Add URL of Marketplace page after it's published
   * [Scalar DL Ledger (BYOL)]() // TODO: Add URL of Marketplace page after it's published
   * [Scalar DL Auditor (BYOL)]() // TODO: Add URL of Marketplace page after it's published

1. Select **Continue to Subscribe**.

1. Sign in to AWS Marketplace using your IAM user.  
   If you have already signed in, this step will be skipped automatically.

1. Read the **Terms and Conditions** and select **Accept Terms**.  
   It takes some time. If it's done, you can see the current date in the **Effective date** column.
   Also, you can see our product on the [Manage subscriptions](https://us-east-1.console.aws.amazon.com/marketplace/home#/subscriptions) page of AWS Console.

## **[BYOL]** Deploy containers on EKS (Amazon Elastic Kubernetes Service) from AWS Marketplace using Scalar Helm Charts

If you subscribe to Scalar products in AWS Marketplace, you can pull container images of Scalar products from the private container registry ([ECR](https://aws.amazon.com/ecr/)) of AWS Marketplace. This section explains how to deploy Scalar products on your [EKS](https://aws.amazon.com/eks/) Cluster from the private container registry of AWS Marketplace.

1. Update the custom values file of the Helm Chart of a Scalar product you want to install.  
   You need to specify the private container registry (ECR) of AWS Marketplace and the version (tag) as the value of `[].image.repository` and `[].image.version (tag)` in the custom values file.  
   * Examples
       * Scalar DB
           * Scalar DB Server (scalardb-custom-values.yaml)
             ```yaml
             envoy:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardb-envoy"
                 version: "1.2.0"
             
             ...
             
             scalardb:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardb-server"
                 tag: "3.5.2"
             ```
       * Scalar DL
           * Scalar DL Ledger (scalardl-ledger-custom-values.yaml)
             ```yaml
             envoy:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-ledger-envoy"
                 version: "1.2.0"
             
             ...
             
             ledger:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-ledger"
                 version: "3.4.1"
             ```
           * Scalar DL Auditor (scalardl-auditor-custom-values.yaml)
             ```yaml
             envoy:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-auditor-envoy"
                 version: "1.2.0"
             
             ...
             
             auditor:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-auditor"
                 version: "3.4.1"
             ```
           * Scalar DL Schema Loader for Ledger (schema-loader-ledger-custom-values.yaml)
             ```yaml
             schemaLoading:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-ledger"
                 version: "3.4.1"
             ```
           * Scalar DL Schema Loader for Auditor (schema-loader-auditor-custom-values.yaml)
             ```yaml
             schemaLoading:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-auditor"
                 version: "3.4.1"
             ```

1. Deploy the Scalar product using the Helm Chart with the above custom values file.
   * Examples
       * Scalar DB
         ```console
         helm install scalardb scalar-labs/scalardb -f ./scalardb-custom-values.yaml
         ```
       * Scalar DL Ledger
         ```console
         helm install scalardl-ledger scalar-labs/scalardl -f ./scalardl-ledger-custom-values.yaml
         ```
       * Scalar DL Auditor
         ```console
         helm install scalardl-auditor scalar-labs/scalardl-audit -f ./scalardl-auditor-custom-values.yaml
         ```
       * Scalar DL Schema Loader (Ledger)
         ```console
         helm install schema-loader scalar-labs/schema-loading -f ./schema-loader-ledger-custom-values.yaml
         ```
       * Scalar DL Schema Loader (Auditor)
         ```console
         helm install schema-loader scalar-labs/schema-loading -f ./schema-loader-auditor-custom-values.yaml
         ```

## **[BYOL]** Deploy containers on Kubernetes other than EKS from AWS Marketplace using Scalar Helm Charts

1. Install the `aws` command according to the [AWS Official Document (Installing or updating the latest version of the AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

1. Configure the AWS CLI with your credentials according to the [AWS Official Document (Configuration basics)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

1. Create a `reg-ecr-mp-secrets` secret resource for pulling the container images from the ECR of AWS Marketplace.
   ```console
   kubectl create secret docker-registry reg-ecr-mp-secrets \
     --docker-server=709825985650.dkr.ecr.us-east-1.amazonaws.com \
     --docker-username=AWS \
     --docker-password=$(aws ecr get-login-password --region us-east-1)
   ```

1. Update the custom values file of the Helm Chart of a Scalar product you want to install.  
   You need to specify the private container registry (ECR) of AWS Marketplace and the version (tag) as the value of `[].image.repository` and `[].image.version (tag)` in the custom values file.  
   Also, you need to specify the `reg-ecr-mp-secrets` as the value of `[].imagePullSecrets`.
   * Examples
       * Scalar DB
           * Scalar DB Server (scalardb-custom-values.yaml)
             ```yaml
             envoy:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardb-envoy"
                 version: "1.2.0"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             
             ...
             
             scalardb:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardb-server"
                 tag: "3.5.2"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             ```
       * Scalar DL
           * Scalar DL Ledger (scalardl-ledger-custom-values.yaml)
             ```yaml
             envoy:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-ledger-envoy"
                 version: "1.2.0"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             
             ...
             
             ledger:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-ledger"
                 version: "3.4.1"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             ```
           * Scalar DL Auditor (scalardl-auditor-custom-values.yaml)
             ```yaml
             envoy:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-auditor-envoy"
                 version: "1.2.0"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             
             ...
             
             auditor:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalar-auditor"
                 version: "3.4.1"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             ```
           * Scalar DL Schema Loader for Ledger (schema-loader-ledger-custom-values.yaml)
             ```yaml
             schemaLoading:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-ledger"
                 version: "3.4.1"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             ```
           * Scalar DL Schema Loader for Auditor (schema-loader-auditor-custom-values.yaml)
             ```yaml
             schemaLoading:
               image:
                 repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-auditor"
                 version: "3.4.1"
               imagePullSecrets:
                 - name: "reg-ecr-mp-secrets"
             ```

1. Deploy the Scalar product using the Helm Chart with the above custom values file.
   * Examples  
     Please refer to the **[BYOL] Deploy containers on EKS (Amazon Elastic Kubernetes Service) from AWS Marketplace using Scalar Helm Charts** section of this document.
