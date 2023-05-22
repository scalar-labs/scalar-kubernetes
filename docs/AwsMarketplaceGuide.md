# How to install Scalar products through AWS Marketplace

Scalar products (ScalarDB, ScalarDL, and their tools) are available in the AWS Marketplace as container images. This guide explains how to install Scalar products through the AWS Marketplace.

Note that some Scalar products are available under commercial licenses, and the AWS Marketplace provides those products as pay-as-you-go pricing or a Bring Your Own License (BYOL) option. If you select pay-as-you-go pricing, AWS will charge you our product license fee based on your usage. If you select BYOL, please make sure you have the appropriate license for the product.

## Subscribe to Scalar products from AWS Marketplace

1. Access to the AWS Marketplace.
   * [ScalarDL Ledger (Pay-As-You-Go)](https://aws.amazon.com/marketplace/pp/prodview-wttioaezp5j6e)
   * [ScalarDL Auditor (Pay-As-You-Go)](https://aws.amazon.com/marketplace/pp/prodview-ke3yiw4mhriuu)
   * [ScalarDB (BYOL)](https://aws.amazon.com/marketplace/pp/prodview-rzbuhxgvqf4d2)
   * [ScalarDL Ledger (BYOL)](https://aws.amazon.com/marketplace/pp/prodview-3jdwfmqonx7a2)
   * [ScalarDL Auditor (BYOL)](https://aws.amazon.com/marketplace/pp/prodview-tj7svy75gu7m6)

1. Select **Continue to Subscribe**.

1. Sign in to AWS Marketplace using your IAM user.  
   If you have already signed in, this step will be skipped automatically.

1. Read the **Terms and Conditions** and select **Accept Terms**.  
   It takes some time. When it's done, you can see the current date in the **Effective date** column.
   Also, you can see our products on the [Manage subscriptions](https://us-east-1.console.aws.amazon.com/marketplace/home#/subscriptions) page of AWS Console.

## **[Pay-As-You-Go]** Deploy containers on EKS (Amazon Elastic Kubernetes Service) from AWS Marketplace using Scalar Helm Charts

By subscribing to Scalar products in the AWS Marketplace, you can pull the container images of Scalar products from the private container registry ([ECR](https://aws.amazon.com/ecr/)) of the AWS Marketplace. This section explains how to deploy Scalar products with pay-as-you-go pricing in your [EKS](https://aws.amazon.com/eks/) cluster from the private container registry.

1. Create an OIDC provider.

   You must create an identity and access management (IAM) OpenID Connect (OIDC) provider to run the AWS Marketplace Metering Service from ScalarDL pods.

   ```console
   eksctl utils associate-iam-oidc-provider --region <REGION> --cluster <EKS_CLUSTER_NAME> --approve
   ```

   For details, see [Creating an IAM OIDC provider for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).

1. Create a service account.

   To allow your pods to run the AWS Marketplace Metering Service, you can use [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

   ```console
   eksctl create iamserviceaccount \
       --name <SERVICE_ACCOUNT_NAME> \
       --namespace <NAMESPACE> \
       --region <REGION> \
       --cluster <EKS_CLUSTER_NAME> \
       --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringFullAccess \
       --approve \
       --override-existing-serviceaccounts
   ```

1. Update the custom values file of the Helm Chart of a Scalar product you want to install.

   You need to specify the private container registry (ECR) of the AWS Marketplace and the version (tag) as the value for `[].image.repository` and `[].image.version (tag)` in the custom values file. You also need to specify the service account name that you created in the previous step as the value for `[].serviceAccount.serviceAccountName` and set `[].serviceAccount.automountServiceAccountToken` to `true`.

   * ScalarDL Examples
      * ScalarDL Ledger (scalardl-ledger-custom-values.yaml)
        ```yaml
        ledger:
          image:
            repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-ledger-aws-payg"
            version: "3.8.1"
          serviceAccount:
            serviceAccountName: "<SERVICE_ACCOUNT_NAME>"
            automountServiceAccountToken: true
        ```
      * ScalarDL Auditor (scalardl-auditor-custom-values.yaml)
        ```yaml
        auditor:
          image:
            repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-auditor-aws-payg"
            version: "3.8.1"
          serviceAccount:
            serviceAccountName: "<SERVICE_ACCOUNT_NAME>"
            automountServiceAccountToken: true
        ```
      * ScalarDL Schema Loader for Ledger (schema-loader-ledger-custom-values.yaml)
        ```yaml
        schemaLoading:
          image:
            repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-ledger-aws-payg"
            version: "3.8.0"
        ```
      * ScalarDL Schema Loader for Auditor (schema-loader-auditor-custom-values.yaml)
        ```yaml
        schemaLoading:
          image:
            repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-auditor-aws-payg"
            version: "3.8.0"
        ```

1. Deploy Scalar products by using Helm Charts in conjunction with the above custom values files.
   * ScalarDL Examples
      * ScalarDL Ledger
        ```console
        helm install scalardl-ledger scalar-labs/scalardl -f ./scalardl-ledger-custom-values.yaml
        ```
      * ScalarDL Auditor
        ```console
        helm install scalardl-auditor scalar-labs/scalardl-audit -f ./scalardl-auditor-custom-values.yaml
        ```
      * ScalarDL Schema Loader (Ledger)
        ```console
        helm install schema-loader scalar-labs/schema-loading -f ./schema-loader-ledger-custom-values.yaml
        ```
      * ScalarDL Schema Loader (Auditor)
        ```console
        helm install schema-loader scalar-labs/schema-loading -f ./schema-loader-auditor-custom-values.yaml
        ```

## **[BYOL]** Deploy containers on EKS (Amazon Elastic Kubernetes Service) from AWS Marketplace using Scalar Helm Charts

By subscribing to Scalar products in the AWS Marketplace, you can pull the container images of Scalar products from the private container registry ([ECR](https://aws.amazon.com/ecr/)) of the AWS Marketplace. This section explains how to deploy Scalar products with the BYOL option in your [EKS](https://aws.amazon.com/eks/) cluster from the private container registry.

1. Update the custom values file of the Helm Chart of a Scalar product you want to install.  
   You need to specify the private container registry (ECR) of AWS Marketplace and the version (tag) as the value of `[].image.repository` and `[].image.version (tag)` in the custom values file.  
   * ScalarDB Examples
      * ScalarDB Server (scalardb-custom-values.yaml)
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
      * ScalarDB GraphQL Server (scalardb-graphql-custom-values.yaml)
        ```yaml
        image:
          repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardb-graphql"
          tag: "3.6.0"
        ```
   * ScalarDL Examples
      * ScalarDL Ledger (scalardl-ledger-custom-values.yaml)
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
      * ScalarDL Auditor (scalardl-auditor-custom-values.yaml)
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
      * ScalarDL Schema Loader for Ledger (schema-loader-ledger-custom-values.yaml)
        ```yaml
        schemaLoading:
          image:
            repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-ledger"
            version: "3.4.1"
        ```
      * ScalarDL Schema Loader for Auditor (schema-loader-auditor-custom-values.yaml)
        ```yaml
        schemaLoading:
          image:
            repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-auditor"
            version: "3.4.1"
        ```

1. Deploy the Scalar products using the Helm Chart with the above custom values files.
   * ScalarDB Examples
      * ScalarDB Server
        ```console
        helm install scalardb scalar-labs/scalardb -f ./scalardb-custom-values.yaml
        ```
      * ScalarDB GraphQL Server
        ```console
        helm install scalardb-graphql scalar-labs/scalardb-graphql -f scalardb-graphql-custom-values.yaml
        ```
   * ScalarDL Examples
      * ScalarDL Ledger
        ```console
        helm install scalardl-ledger scalar-labs/scalardl -f ./scalardl-ledger-custom-values.yaml
        ```
      * ScalarDL Auditor
        ```console
        helm install scalardl-auditor scalar-labs/scalardl-audit -f ./scalardl-auditor-custom-values.yaml
        ```
      * ScalarDL Schema Loader (Ledger)
        ```console
        helm install schema-loader scalar-labs/schema-loading -f ./schema-loader-ledger-custom-values.yaml
        ```
      * ScalarDL Schema Loader (Auditor)
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
   * ScalarDB Examples
       * ScalarDB Server (scalardb-custom-values.yaml)
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
       * ScalarDB GraphQL Server (scalardb-graphql-custom-values.yaml)
         ```yaml
         image:
           repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardb-graphql"
           tag: "3.6.0"
         imagePullSecrets:
           - name: "reg-ecr-mp-secrets"
         ```
   * ScalarDL Examples
       * ScalarDL Ledger (scalardl-ledger-custom-values.yaml)
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
       * ScalarDL Auditor (scalardl-auditor-custom-values.yaml)
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
       * ScalarDL Schema Loader for Ledger (schema-loader-ledger-custom-values.yaml)
         ```yaml
         schemaLoading:
           image:
             repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-ledger"
             version: "3.4.1"
           imagePullSecrets:
             - name: "reg-ecr-mp-secrets"
         ```
       * ScalarDL Schema Loader for Auditor (schema-loader-auditor-custom-values.yaml)
         ```yaml
         schemaLoading:
           image:
             repository: "709825985650.dkr.ecr.us-east-1.amazonaws.com/scalar/scalardl-schema-loader-auditor"
             version: "3.4.1"
           imagePullSecrets:
             - name: "reg-ecr-mp-secrets"
         ```

1. Deploy the Scalar products using the Helm Chart with the above custom values files.
   * Examples  
     Please refer to the **[BYOL] Deploy containers on EKS (Amazon Elastic Kubernetes Service) from AWS Marketplace using Scalar Helm Charts** section of this document.
