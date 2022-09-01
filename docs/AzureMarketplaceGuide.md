# How to install Scalar products through Azure Marketplace

Scalar products (Scalar DB, Scalar DL, and their tools) are provided in Azure Marketplace as container offers. This guide explains how to install Scalar products through Azure Marketplace.

Note that some Scalar products are licensed under commercial licenses, and the Azure Marketplace provides them as BYOL (Bring Your Own License). Please make sure you have appropriate licenses.

## Get Scalar products from Microsoft Azure Marketplace

1. Access to the Microsoft Azure Marketplace.
   * [Scalar DB](https://azuremarketplace.microsoft.com/en/marketplace/apps/scalarinc.scalardb)
   * [Scalar DL](https://azuremarketplace.microsoft.com/en/marketplace/apps/scalarinc.scalardl)

1. Select **Get It Now**.

1. Sign in to Azure Marketplace using your work email address.  
   Please use the work email address that is used as an account of Microsoft Azure.  
   If you have already signed in, this step will be skipped automatically.

1. Input your information.  
Note that **Company** is not required, but please enter it.

1. Select a **Software plan** you need from the pull-down.  
   **Software plan** means a combination of the container image and the license. Please select the *Software plan* you use.

1. Select **Continue**.  
   After selecting the **Continue**, it automatically moves to the Azure Portal.

1. Create a private container registry (Azure Container Registry).  
   Follow the on-screen instructions, please create your private container registry.  
   The container images of Scalar products will be copied to your private container registry.

1. Repeat these steps as needed.  
   You need several container images to run Scalar products on Kubernetes, but Azure Marketplace copies only one container image at a time. So, you need to subscribe to several software plans (repeat subscribe operation) as needed.
   * Container images that you need are the following.
        * Scalar DB
            * Scalar DB Server Default (2vCPU, 4GiB Memory)
            * Scalar DB Server Envoy Proxy
            * Scalar DB GraphQL Server (optional)
            * Scalar DB SQL Server (optional)
        * Scalar DL
            * Scalar DL Ledger Default (2vCPU, 4GiB Memory)
            * Scalar DL Auditor Default (2vCPU, 4GiB Memory)
                * The **Scalar DL Auditor** is optional. If you use the **Scalar DL Auditor**, subscribe to it.
            * Scalar DL Schema Loader
            * Scalar DL Envoy

Now, you can pull the container images of the Scalar products from your private container registry.
Please refer to the [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry/) for more details about the Azure Container Registry.

## Deploy containers on AKS (Azure Kubernetes Service) from your private container registry using Scalar Helm Charts

1. Specify your private container registry (Azure Container Registry) when you create an AKS cluster.
   * GUI (Azure Portal)  
     At the **Azure Container Registry** parameter in the **Integrations** tab, please specify your private container registry.
   * CLI ([az aks create](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create) command)  
     Please specify `--attach-acr` flag with the name of your private container registry. Also, you can configure Azure Container Registry integration for existing AKS clusters using [az aks update](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-update) command with `--attach-acr` flag. Please refer to the [Azure Official Document](https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration) for more details.

1. Update the custom values file of the Helm Chart of a Scalar product you want to install.  
   You need to specify your private container registry and the version (tag) as the value of `[].image.repository` and `[].image.version (tag)` in the custom values file.  
   * Scalar DB Examples
      * Scalar DB Server (scalardb-custom-values.yaml)
        ```yaml
        envoy:
          image:
            repository: "example.azurecr.io/scalarinc/scalardb-envoy"
            version: "1.2.0"
        
        ...
        
        scalardb:
          image:
            repository: "example.azurecr.io/scalarinc/scalardb-server"
            tag: "3.5.2"
        ```
      * Scalar DB GraphQL Server (scalardb-graphql-custom-values.yaml)
        ```yaml
        image:
          repository: "example.azurecr.io/scalarinc/scalardb-graphql"
          tag: "3.6.0"
        ```
   * Scalar DL Examples
      * Scalar DL Ledger (scalardl-ledger-custom-values.yaml)
        ```yaml
        envoy:
          image:
            repository: "example.azurecr.io/scalarinc/scalardl-envoy"
            version: "1.2.0"
        
        ...
        
        ledger:
          image:
            repository: "example.azurecr.io/scalarinc/scalar-ledger"
            version: "3.4.0"
        ```
      * Scalar DL Auditor (scalardl-auditor-custom-values.yaml)
        ```yaml
        envoy:
          image:
            repository: "example.azurecr.io/scalarinc/scalardl-envoy"
            version: "1.2.0"
        
        ...
        
        auditor:
          image:
            repository: "example.azurecr.io/scalarinc/scalar-auditor"
            version: "3.4.0"
        ```
      * Scalar DL Schema Loader (schema-loader-custom-values.yaml)
        ```yaml
        schemaLoading:
          image:
            repository: "example.azurecr.io/scalarinc/scalardl-schema-loader"
            version: "3.4.0"
        ```

1. Deploy the Scalar product using the Helm Chart with the above custom values file.
   * Scalar DB Examples
      * Scalar DB Server
        ```console
        helm install scalardb scalar-labs/scalardb -f ./scalardb-custom-values.yaml
        ```
      * Scalar DB GraphQL Server
        ```console
        helm install scalardb-graphql scalar-labs/scalardb-graphql -f scalardb-graphql-custom-values.yaml
        ```
   * Scalar DL Examples
      * Scalar DL Ledger
        ```console
        helm install scalardl-ledger scalar-labs/scalardl -f ./scalardl-ledger-custom-values.yaml
        ```
      * Scalar DL Auditor
        ```console
        helm install scalardl-auditor scalar-labs/scalardl-audit -f ./scalardl-auditor-custom-values.yaml
        ```
      * Scalar DL Schema Loader
        ```console
        helm install schema-loader scalar-labs/schema-loading -f ./schema-loader-custom-values.yaml
        ```

## Deploy containers on Kubernetes other than AKS (Azure Kubernetes Service) from your private container registry using Scalar Helm Charts

1. Install the `az` command according to the [Azure Official Document (How to install the Azure CLI)](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

1. Sign in with Azure CLI.
   ```console
   az login
   ```

1. Create a **service principal** for authentication to your private container registry according to the [Azure Official Document (Azure Container Registry authentication with service principals)](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-service-principal).  
   We use the **Service principal ID** and the **Service principal password** in the next step.

1. Create a `reg-acr-secrets` secret resource for pulling the container images from your private container registry.
   ```console
   kubectl create secret docker-registry reg-acr-secrets \
     --docker-server=<your private container registry login server> \
     --docker-username=<Service principal ID> \
     --docker-password=<Service principal password>
   ```

1. Update the custom values file of the Helm Chart of a Scalar product you want to install.  
   You need to specify your private container registry and the version (tag) as the value of `[].image.repository` and `[].image.version (tag)` in the custom values file.  
   Also, you need to specify the `reg-acr-secrets` as the value of `[].imagePullSecrets`.
   * Scalar DB Examples
      * Scalar DB Server (scalardb-custom-values.yaml)
        ```yaml
        envoy:
          image:
            repository: "example.azurecr.io/scalarinc/scalardb-envoy"
            version: "1.2.0"
          imagePullSecrets:
            - name: "reg-acr-secrets"
        
        ...
        
        scalardb:
          image:
            repository: "example.azurecr.io/scalarinc/scalardb-server"
            tag: "3.5.2"
          imagePullSecrets:
            - name: "reg-acr-secrets"
        ```
      * Scalar DB GraphQL Server (scalardb-graphql-custom-values.yaml)
        ```yaml
        image:
          repository: "example.azurecr.io/scalarinc/scalardb-graphql"
          tag: "3.6.0"
        imagePullSecrets:
          - name: "reg-acr-secrets"
        ```
   * Scalar DL Examples
      * Scalar DL Ledger (scalardl-ledger-custom-values.yaml)
        ```yaml
        envoy:
          image:
            repository: "example.azurecr.io/scalarinc/scalardl-envoy"
            version: "1.2.0"
          imagePullSecrets:
            - name: "reg-acr-secrets"
        
        ...
        
        ledger:
          image:
            repository: "example.azurecr.io/scalarinc/scalar-ledger"
            version: "3.4.0"
          imagePullSecrets:
            - name: "reg-acr-secrets"
        ```
      * Scalar DL Auditor (scalardl-auditor-custom-values.yaml)
        ```yaml
        envoy:
          image:
            repository: "example.azurecr.io/scalarinc/scalardl-envoy"
            version: "1.2.0"
          imagePullSecrets:
            - name: "reg-acr-secrets"
        
        ...
        
        auditor:
          image:
            repository: "example.azurecr.io/scalarinc/scalar-auditor"
            version: "3.4.0"
          imagePullSecrets:
            - name: "reg-acr-secrets"
        ```
      * Scalar DL Schema Loader (schema-loader-custom-values.yaml)
        ```yaml
        schemaLoading:
          image:
            repository: "example.azurecr.io/scalarinc/scalardl-schema-loader"
            version: "3.4.0"
          imagePullSecrets:
            - name: "reg-acr-secrets"
        ```

1. Deploy the Scalar product using the Helm Chart with the above custom values file.
   * Examples  
     Please refer to the **Deploy containers on AKS (Azure Kubernetes Service) from your private container registry using Scalar Helm Charts** section of this document.
