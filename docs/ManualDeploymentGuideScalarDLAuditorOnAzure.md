# Deploy Scalar DL Auditor on Azure

This guide shows you how to manually deploy Scalar DL Auditor on a managed database service and a managed Kubernetes service in Azure as part of deploying Scalar DL for production.
If you have not deployed Scalar DL Ledger, please follow [Deploy Scalar DL on Azure](ManualDeploymentGuideScalarDLOnAzure.md) guide.

## What we create

![image](images/auditor-arch.png)

In this guide, we will create the following components for auditor.

An Azure Virtual Network associated with a Resource Group.
An AKS cluster with 2 node pools.
A managed database service.
A Cosmos DB Account.
A Bastion instance with a public IP.
Azure container insights.

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

* [Helm](https://helm.sh/docs/intro/install/): Helm command-line tool to manage releases in the AKS cluster, Helm version 3.2.1 or latest is required. In this guide, it is used to deploy Scalar Auditor and Schema loading helm charts to the AKS cluster.
* You must create a Github Personal Access Token (PAT) on the basis of Github official document with read:packages scope, it is used to access the `scalar-auditor` and `scalardl-schema-loader` container images from GitHub Packages.

### Requirements

* You must have the authority to pull `scalar-auditor` and `scalardl-schema-loader` container images.
* You must confirm that the replica count of the auditor and envoy pods in the `scalardl-audit-custom-values.yaml` file is equal to the number of nodes in the scalardlpool.
* You must keep an equal number of pods for envoy, ledger and auditor.

### Steps

1. Download the following Scalar DL configuration files from the [scalar-kubernetes](https://github.com/scalar-labs/scalar-kubernetes/tree/audit-guide-aks/conf) repository.
Note that they are going to be versioned in the future, so you might want to change the branch to use a proper version.
    * Scalardl-audit-custom-values.yaml
    * Schema-loading-custom-values.yaml
1. Update the database configuration in `scalarAuditorConfiguration` and `schemaLoading` sections as specified in the [Configure Scalar DL](ConfigureScalarDL.md) guide.
1. Create the docker-registry secret for pulling the Scalar Auditor images from GitHub Packages.
   ```console
   kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token> 
   ```
1. Create the auditor-key secret for sign the request before sending it to Ledger and validate the request given from Ledger.
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

You can follow step 6 in the [Deploy Scalar DL on Azure](ManualDeploymentGuideScalarDLOnAzure.md#step-6-monitor-the-cluster) guide to enable the monitor service.

## Step 5. Checklist for confirming Scalar DL Auditor deployments

### Confirm Scalar DL Auditor deployment

* Make sure the auditor schema is properly created in the underlying database service.
* You can check if the pods and the services are properly deployed by running the `kubectl get pods,services -o wide` command on the bastion.
    * You should confirm the status of all auditor and envoy pods are Running.
    * You should confirm the EXTERNAL-IP of Scalar auditor envoy service is created.
    
    ```console
    $ kubectl get pod,node,svc -o wide
    NAME                                                                  READY   STATUS      RESTARTS   AGE     IP            NODE                                   NOMINATED NODE   READINESS GATES
    pod/load-audit-schema-schema-loading-tkpqd                            0/1     Completed   0          6m36s   10.45.4.94    aks-scalardlpool-52642482-vmss000001   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-auditor-5dd6fdfd6b-4fkbw   1/1     Running     0          2m42s   10.45.4.47    aks-scalardlpool-52642482-vmss000000   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-auditor-5dd6fdfd6b-tv2pf   1/1     Running     0          2m42s   10.45.4.87    aks-scalardlpool-52642482-vmss000001   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-auditor-5dd6fdfd6b-xbsq5   1/1     Running     0          2m42s   10.45.4.108   aks-scalardlpool-52642482-vmss000002   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-6thkf     1/1     Running     0          2m42s   10.45.4.78    aks-scalardlpool-52642482-vmss000001   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-h549q     1/1     Running     0          2m42s   10.45.4.134   aks-scalardlpool-52642482-vmss000002   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-vs7x4     1/1     Running     0          2m42s   10.45.4.32    aks-scalardlpool-52642482-vmss000000   <none>           <none>
    
    NAME                                        STATUS   ROLES   AGE    VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
    node/aks-agentpool-52642482-vmss000000      Ready    agent   106m   v1.19.13   10.45.4.158   <none>        Ubuntu 18.04.6 LTS   5.4.0-1059-azure   containerd://1.4.9+azure
    node/aks-agentpool-52642482-vmss000001      Ready    agent   106m   v1.19.13   10.45.5.13    <none>        Ubuntu 18.04.6 LTS   5.4.0-1059-azure   containerd://1.4.9+azure
    node/aks-agentpool-52642482-vmss000002      Ready    agent   106m   v1.19.13   10.45.5.124   <none>        Ubuntu 18.04.6 LTS   5.4.0-1059-azure   containerd://1.4.9+azure
    node/aks-scalardlpool-52642482-vmss000000   Ready    agent   106m   v1.19.13   10.45.4.5     <none>        Ubuntu 18.04.6 LTS   5.4.0-1059-azure   containerd://1.4.9+azure
    node/aks-scalardlpool-52642482-vmss000001   Ready    agent   106m   v1.19.13   10.45.4.56    <none>        Ubuntu 18.04.6 LTS   5.4.0-1059-azure   containerd://1.4.9+azure
    node/aks-scalardlpool-52642482-vmss000002   Ready    agent   106m   v1.19.13   10.45.4.107   <none>        Ubuntu 18.04.6 LTS   5.4.0-1059-azure   containerd://1.4.9+azure
    
    NAME                                                           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                           AGE     SELECTOR
    service/kubernetes                                             ClusterIP      10.0.0.1      <none>        443/TCP                           110m    <none>
    service/my-release-scalar-audit-scalardl-audit-envoy           LoadBalancer   10.0.75.220   10.45.8.4     40051:32475/TCP,40052:30685/TCP   2m42s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalar-audit-scalardl-audit-envoy-metrics   ClusterIP      10.0.136.32   <none>        9001/TCP                          2m42s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalar-audit-scalardl-audit-headless        ClusterIP      None          <none>        50051/TCP,50053/TCP,50052/TCP     2m42s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalar-audit-scalardl-audit-metrics         ClusterIP      10.0.22.255   <none>        8080/TCP                          2m42s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
    ```
