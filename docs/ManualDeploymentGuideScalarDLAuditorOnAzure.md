# Deploy Scalar DL Auditor on Azure

Scalar DL Auditor is an optional component that manages the identical states of Ledger and helps Scalar DL clients to detect Byzantine faults.
This guide shows you how to manually deploy Scalar DL Auditor on a managed database service and a managed Kubernetes service in Azure as part of deploying Scalar DL for production.

## What we create

![image](images/auditor-arch.png)

In this guide, we will create the following components for auditor.

* An Azure Virtual Network associated with a Resource Group.
* An AKS cluster with 2 node pools.
* A managed database service.
    * A Cosmos DB Account.
* A Bastion instance with a public IP.
* Azure container insights.

## Prerequisites

* Scalar DL Ledger deployment with Auditor configuration completed.

## Step 1. Create environment

It is highly recommended to deploy Scalar DL Auditor in a different administrative domain from the one for Ledger in production because a single fully-privileged administrator can do any malicious activities in a single administrative domain.
However, for ease of explanation, we deploy Auditor in the same administrative domain as Ledger (i.e., a different cluster on the same subscription) in this guide.

You need to configure a network, Scalar DL supported database, and AKS service in a different administrative domain for Auditor deployment using the steps of creating a Ledger environment.

### Requirements

* You must create subnets in a different address range than Ledger and Client.
* You must configure your network.
* You must set up a database.
* You must configure AKS.

### Recommendations

* You should deploy Ledger and Auditor in separate administrative domains.

### Steps

* Follow step 1 to step 3 in the [Deploy Scalar DL on Azure](./ManualDeploymentGuideScalarDLOnAzure.md) guide to create an Scalar DL Auditor environment.

## Step 2. Peer the Virtual Networks

In this guide, Ledger, Auditor, and Client applications are deployed on the private subnet of the different virtual networks,
so you need to add peering for internal communication between the Auditor, Ledger, and Client application.

### Requirements

* You must create 3 peering between 3 Virtual Networks.

### Recommendations

* You should create Network Security Groups for Ledger and Auditor subnets.
* You should restrict all access from the Auditor and Client except scalardl envoy LoadBalancer ports (50051 and 50052) in the Ledger Network Security Group. 
* You should restrict all access from the Ledger and Client except scalardl auditor envoy LoadBalancer ports (40051 and 40052) in the Auditor Network Security Group.

### Steps

* Create 3 peering connections between the Ledger, Auditor and Client Virtual Networks on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-peering).
    * Peering between Ledger and Auditor.
    * Peering between Ledger and Client.
    * Peering between Auditor and Client.
* Create the network security groups for Ledger and Auditor subnet on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/virtual-network/manage-network-security-group).
* Add new Inbound rule to restrict unwanted access to Ledger and Auditor. (By default, all subnets and ports are open between VNet after peering)
    * Add new Inbound rules to the Ledger Network Security Group to allow the Ledger Envoy LoadBalancer (50051, 50052) access from the Auditor and Client.
        * You must set a higher priority than the Ledger inbound deny rule.
    * Add new Inbound rules to the Ledger Network Security Group to deny all access from the Auditor and Client.
        * You must set a lower priority than the Ledger inbound allow rule.   
    * Add new Inbound rules to the Auditor Network Security Group to allow the Auditor Envoy LoadBalancer (40051, 40052) access from the Ledger and Client.
        * You must set a higher priority than the auditor inbound deny rule.
    * Add new Inbound rules to the Auditor Network Security Group to deny all access from the Ledger and Client.
        * You must set a lower priority than the auditor inbound allow rule.

Note: - We expect you have created the Client Virtual Networks for your application deployment.

## Step 3. Install Scalar DL Auditor

### Prerequisites

You must install Helm on your bastion to deploy [helm-charts](https://github.com/scalar-labs/helm-charts):

* [Helm](https://helm.sh/docs/intro/install/): Helm command-line tool to manage releases in the AKS cluster, Helm version 3.2.1 or latest is required. In this guide, it is used to deploy Scalar DL Auditor and Schema loading helm charts to the AKS cluster.
* You must create a Github Personal Access Token (PAT) on the basis of Github official document with `read:packages` scope, it is used to access the `scalar-auditor` and `scalardl-schema-loader` container images from GitHub Packages.

### Requirements

* You must have the authority to pull `scalar-auditor` and `scalardl-schema-loader` container images.

### Recommendations

* You should set the replica count of the Auditor and Envoy pods in the `scalardl-audit-custom-values.yaml` file, which should be equal to the number of nodes in the `scalardlpool`. Otherwise, there is a chance for resource shortage for pod creation.
* You should create an equal number of pods and Envoy pods for Ledger and Auditor for better performance.

### Steps

1. Download the following Scalar DL configuration files from the [scalar-kubernetes](https://github.com/scalar-labs/scalar-kubernetes/tree/audit-guide-aks/conf) repository.
Note that they are going to be versioned in the future, so you might want to change the branch to use a proper version.
    * scalardl-audit-custom-values.yaml
    * schema-loading-custom-values.yaml
1. Update the database configuration in `scalarAuditorConfiguration` and `schemaLoading` sections as specified in the [Configure Scalar DL](ConfigureScalarDL.md) guide.
1. Create the `docker-registry` secret for pulling the Scalar DL Auditor images from GitHub Packages.
   ```console
   kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token> 
   ```
1. Create the `auditor-key` secret for sign the request before sending it to Ledger and validate the request given from Ledger.
   ```console
   kubectl create secret generic auditor-keys --from-file=certificate=conf/auditor-cert.pem --from-file=private-key=conf/auditor-key.pem 
   ```
1. Run the Helm commands on the bastion to install Scalar DL Auditor on AKS.
   ```console
    # Add Helm charts
    helm repo add scalar-labs https://scalar-labs.github.io/helm-charts
    
    # List the Scalar charts.
    helm search repo scalar-labs
    
    # Load Schema for Scalar DL Auditor install with a release name `load-audit-schema`
    helm upgrade --version <chart version> --install load-audit-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml --set schemaLoading.schemaType=auditor

    # Install Scalar DL Auditor with a release name `my-release-scalar-audit`
    helm upgrade --version <chart version> --install my-release-scalar-audit scalar-labs/scalardl-audit --namespace default -f scalardl-audit-custom-values.yaml
   ```

Note:
* The same commands can be used to upgrade the pods.
* Release name `my-release-scalar-audit` can be changed at your convenience.
* The chart version can be obtained from `helm search repo scalar-labs` output.
* `helm ls -a` command can be used to list currently installed releases.
* You should confirm the `load-audit-schema` deployment has been completed with `kubectl get pods -o wide` before installing Scalar DL Auditor.
* Follow the [Maintain Scalar DL Pods](./MaintainPods-1.md) for maintaining Scalar DL pods with Helm.
* Register the certificate for the Ledger and Auditor before starting the client application.
    * Ledger needs to register its certificate to Auditor, and Auditor needs to register its certificate to Ledger.

## Step 4. Monitor the cluster

Follow step 6 in the [Deploy Scalar DL on Azure](./ManualDeploymentGuideScalarDLOnAzure.md#step-6-monitor-the-cluster) guide to enable the monitor services.

## Step 5. Checklist for confirming Scalar DL Auditor deployments

### Confirm Scalar DL Auditor deployment

* Make sure the Auditor schema is properly created in the underlying database service.
* You can check if the pods and the services are properly deployed by running the `kubectl get pods,services -o wide` command on the bastion.
    * You should confirm the status of all Auditor and Envoy pods are Running.
    * You should confirm the `EXTERNAL-IP` of Scalar DL Auditor envoy service is created.
    
   ```console
    $ kubectl get pod,services -o wide
    NAME                                                                  READY   STATUS      RESTARTS   AGE     IP            NODE                                   NOMINATED NODE   READINESS GATES
    pod/load-audit-schema-schema-loading-tkpqd                            0/1     Completed   0          6m36s   10.45.4.94    aks-scalardlpool-52642482-vmss000001   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-auditor-5dd6fdfd6b-4fkbw   1/1     Running     0          2m42s   10.45.4.47    aks-scalardlpool-52642482-vmss000000   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-auditor-5dd6fdfd6b-tv2pf   1/1     Running     0          2m42s   10.45.4.87    aks-scalardlpool-52642482-vmss000001   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-auditor-5dd6fdfd6b-xbsq5   1/1     Running     0          2m42s   10.45.4.108   aks-scalardlpool-52642482-vmss000002   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-6thkf     1/1     Running     0          2m42s   10.45.4.78    aks-scalardlpool-52642482-vmss000001   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-h549q     1/1     Running     0          2m42s   10.45.4.134   aks-scalardlpool-52642482-vmss000002   <none>           <none>
    pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-vs7x4     1/1     Running     0          2m42s   10.45.4.32    aks-scalardlpool-52642482-vmss000000   <none>           <none>
    
    NAME                                                           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                           AGE     SELECTOR
    service/kubernetes                                             ClusterIP      10.0.0.1      <none>        443/TCP                           110m    <none>
    service/my-release-scalar-audit-scalardl-audit-envoy           LoadBalancer   10.0.75.220   10.45.8.4     40051:32475/TCP,40052:30685/TCP   2m42s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalar-audit-scalardl-audit-envoy-metrics   ClusterIP      10.0.136.32   <none>        9001/TCP                          2m42s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalar-audit-scalardl-audit-headless        ClusterIP      None          <none>        50051/TCP,50053/TCP,50052/TCP     2m42s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalar-audit-scalardl-audit-metrics         ClusterIP      10.0.22.255   <none>        8080/TCP                          2m42s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
   ```
