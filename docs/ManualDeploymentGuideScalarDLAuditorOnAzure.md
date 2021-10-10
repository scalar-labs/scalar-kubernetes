# Deploy Scalar DL Auditor on Azure

This guide shows you how to manually deploy Scalar DL Auditor on a managed database service and a managed Kubernetes service in Azure as part of deploying Scalar DL for production.
If you have not deployed Scalar DL Ledger, please follow [Deploy Scalar DL on Azure](ManualDeploymentGuideScalarDLOnAzure.md) guide.

## Prerequisites

* Scalar DL Ledger deployment with auditor configuration completed.

## Step 1. Create environment

Scalar DL Auditor component is implemented to detect Byzantine faults,
it manages the identical states of Ledger so you need to deploy the ledger and auditor in separate clusters to manage the cluster for different admins / owners. Otherwise, there is a possibility of forgery.

In this guide the auditor will be deployed in different clusters on the same subscription.
For more security, you can deploy the ledger and auditor on different subscriptions.

### Requirements

* You must follow step 1 to step 3 in the [Deploy Scalar DL on Azure](ManualDeploymentGuideScalarDLOnAzure.md) guide to create an Scalar DL Auditor environment.
* You must create different clusters for ledger and auditor.
* You must set up a separate database for the auditor.

### Recommendations

* You should deploy ledger and auditor in separate subscriptions for production use.
* Ledger and auditor should be managed by different administrators.

## Step 2. Peer the Virtual Networks

This section shows how to peer the virtual networks for Scalar DL deployment.

In this guide the ledger and the auditor are deployed on the private subnet of the different virtual networks,
so you need to create peering for internal communication between the auditor, ledger and client SDK(application). 

### Requirements

* You must create a peering between the virtual network created for ledger and auditor services.
* You must create a peering between the virtual network created for ledger and client SDK (application).
* You must create a peering between the virtual network created for auditor and client SDK (application).

### Steps

* Create the peering on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-peering) with the above requirements.

## Step 3. Install Scalar DL Auditor

### Prerequisites

You must install Helm on your bastion to deploy helm-charts:

* Helm: Helm command-line tool to manage releases in the AKS cluster, Helm version 3.2.1 or latest is required. In this guide, it is used to deploy Scalar Auditor and Schema loading helm charts to the AKS cluster.
* You must create a Github Personal Access Token (PAT) on the basis of Github official document with read:packages scope, it is used to access the scalar-auditor and scalardl-schema-loader container images from GitHub Packages.

### Requirements

* You must have the authority to pull scalar-auditor and scalardl-schema-loader container images.
* You must confirm that the replica count of the ledger and envoy pods in the scalardl-audit-custom-values.yaml file is equal to the number of nodes in the scalardlpool.

### Steps

1. Download the following Scalar DL configuration files from the [scalar-kubernetes](https://github.com/scalar-labs/scalar-kubernetes/tree/audit-guide-aks/conf) repository.
Note that they are going to be versioned in the future, so you might want to change the branch to use a proper version.
    * Scalardl-audit-custom-values.yaml
    * Schema-loading-custom-values.yaml
1. Update the database configuration in scalarAuditorConfiguration and schemaLoading sections as specified in the [Configure Scalar DL](ConfigureScalarDL.md) guide.
1. Create the docker-registry secret for pulling the Scalar Auditor images from GitHub Packages.
   ```console
   kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token> 
   ```
1. Create a proper auditor-key secret to sign a request before sending the request to Ledger and validate a request given from Ledger.
   ```console
   kubectl create secret generic auditor-keys --from-file=certificate=conf/auditor-cert.pem --from-file=private-key=conf/auditor-key.pem 
   ```
1. Run the Helm commands on the bastion to install Scalar Auditor on AKS.
   ```console
    # Add Helm charts
    helm repo add scalar-labs https://scalar-labs.github.io/helm-charts
    
    # List the Scalar charts.
    helm search repo scalar-labs
    
    # Load Schema for Scalar Auditor install with a release name `load-audit-schema`
   helm upgrade --version <chart version> --install load-audit-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml --set schemaLoading.schemaType=auditor
   
   # Install Scalar Auditor with a release name `my-release-scalar-audit`
   helm upgrade --version <chart version> --install my-release-scalar-audit scalar-labs/scalardl-audit --namespace default -f scalardl-audit-custom-values.yaml
   ```

Note:
* The same commands can be used to upgrade the pods.
* Release name `my-release-scalar-audit` can be changed at your convenience.
* The chart version can be obtained from `helm search repo scalar-labs` output
* `helm ls -a` command can be used to list currently installed releases.
* You should confirm the load-audit-schema deployment has been completed with `kubectl get pods -o wide` before installing Scalar auditor.

## Step 4. Monitor the cluster

## Step 5. Checklist for confirming Scalar DL Auditor deployments

### Confirm Scalar DL Auditor deployment

* Make sure the auditor schema is properly created in the underlying database service.
* You can check if the pods and the services are properly deployed by running the `kubectl get pods,services -o wide` command on the bastion.
    * You should confirm the status of all auditor and envoy pods are Running.
    * You should confirm the EXTERNAL-IP of Scalar auditor envoy service is created.
