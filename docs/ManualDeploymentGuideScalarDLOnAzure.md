# Deploy Scalar DL on Azure

Scalar DL is a database-agnostic distributed ledger middleware containerized with Docker.
It can be deployed on various platforms and is recommended to be deployed on managed services for production to achieve high availability, scalability, and maintainability.
This guide shows you how to manually deploy Scalar DL on a managed database service and a managed Kubernetes service in Azure as a starting point for deploying Scalar DL for production.

Scalar DL Auditor is an optional component that manages the identical states of Ledger to help clients to detect Byzantine faults.
Using Auditor brings great benefit from the security perspective but it comes with extra processing costs.

Note: Optional sections are mandatory to enable the auditor service.

## What we create

![image](images/azure-diagram.png)

In this guide, we will create the following components.

* An Azure Virtual Network associated with a Resource Group.
* An AKS cluster with 2 node pools.
* A managed database service.
    * A Cosmos DB Account.
* A Bastion instance with a public IP.
* Azure container insights.

## Prerequisites

You must have required permissions as specified in [Cloud permissions document](./CloudPermissionsForScalarDLOnAKS.md) to create cloud resources to deploy Scalar DL on Azure.

## Step 1. Configure your network

Configure a secure network with your organizational or application standards.
Scalar DL handles highly sensitive data of your application, so you should create a highly secure network for production.
This section shows how to configure a secure network for Scalar DL deployments.

### Requirements

* You must create a virtual network with a subnet for bastion.
* You must create 2 subnets for AKS, one subnet must be created with the name `k8s_ingress` to create an envoy load balancer.

### Recommendations

* You should create a bastion server to manage the Kubernetes cluster for production or you can use VPN to access from local machine.
* You should create subnets for AKS with prefix of at least `/22` on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni).

### Steps

* Create a Resource group on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups).
* Create an Azure virtual network on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-portal) with the above requirements and recommendations.
* Create subnets on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet) with the above requirements and recommendations.
* Create a virtual machine to use as a bastion server on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal).

## Step 2. Set up a database

In this section, you will set up a database for Scalar DL.

### Requirements

* You must have a database that Scalar DL supports.

### Steps

* Follow [Set up a database guide](./SetupDatabase.md) to set up a database for Scalar DL.

## Step 3. Configure AKS

This section shows how to configure a Kubernetes service for Scalar DL deployment.

### Prerequisites

Install the following tools on the bastion for controlling the AKS cluster:
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli): In this guide, Azure CLI is used to create a kubeconfig file to access the AKS cluster.
* [kubectl](https://kubernetes.io/docs/tasks/tools/): Kubernetes command-line tool to manage AKS cluster. Kubectl 1.19 or higher is required.

### Requirements

* You must have an AKS cluster with Kubernetes version **1.19** or higher for Scalar DL deployment.
* You must create a new `user node pool` with the name `scalardlpool` for Scalar DL deployment.
* You must create a Kubernetes cluster with `service principal` as the Authentication method.
* You must create a Kubernetes cluster with `Azure CNI`.
* You must select the subnet other than `k8s_ingress` subnet for creating the AKS cluster.
* You must assign `network contributor` role to service principal for creating the envoy load balancer on `k8s_ingress` subnet.

### Recommendations

* You should use Kubernetes node size `Standard D4s v3` for Scalar DL node pool to deploy ledger and auditor.
* You should use Kubernetes node size `Standard D2s v3` for Scalar DL node pool to deploy only ledger.
* You should create 3 nodes in each node group for high availability in production.
* You should configure `Autoscale` for the node pools If you want to scale the nodes.

### Steps

* Create an AKS cluster on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal#create-an-aks-cluster) with the above requirements and recommendations.
* Configure kubectl to connect to your Kubernetes cluster using the `az aks get-credentials` command.

    ```console
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

## Step 4. Install Scalar DL

In this section, we will deploy Scalar DL on the AKS cluster using [Helm charts](https://github.com/scalar-labs/helm-charts).

### Prerequisites

You must install Helm on your bastion to deploy helm-charts:

* [Helm](https://helm.sh/docs/intro/install/): Helm command-line tool to manage releases in the AKS cluster, Helm version 3.2.1 or latest is required.
  In this guide, it is used to deploy Scalar DL and Schema loading helm charts to the AKS cluster.

* You must create a Github Personal Access Token (PAT) on the basis of [Github official document](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)
  with `read:packages` scope, it is used to access the `scalar-ledger` and `scalardl-schema-loader` container images from GitHub Packages.

### Requirements

* You must have the authority to pull `scalar-ledger` and `scalardl-schema-loader` container images.
* You must confirm that the replica count of the ledger and envoy pods in the `scalardl-custom-values.yaml` file is equal to the number of nodes in the `scalardlpool`.

### Steps

1. Download the following Scalar DL configuration files from [the scalar-kubernetes repository](https://github.com/scalar-labs/scalar-kubernetes/tree/master/conf). Note that they are going to be versioned in the future, so you might want to change the branch to use a proper version.
    * scalardl-custom-values.yaml
    * scalardl-audit-custom-values.yaml [Optional]
    * schema-loading-custom-values.yaml

2. Update the database configuration in `scalarLedgerConfiguration`, `scalarAuditorConfiguration` and `schemaLoading` sections as specified in [configure Scalar DL guide](./ConfigureScalarDL.md).

3. Create the docker-registry secret for pulling the Scalar DL images from GitHub Packages.
    
   ```console
    kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token>
    ```
   
4. Run the Helm commands on the bastion to install Scalar DL on AKS.
    
   ```console
    # Add Helm charts
      helm repo add scalar-labs https://scalar-labs.github.io/helm-charts
    
    # List the Scalar charts.
      helm search repo scalar-labs
    
    # Load Schema for Scalar DL install with a release name `load-schema`
      helm upgrade --version <chart version> --install load-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml
   
    # Install Scalar DL with a release name `my-release-scalardl`
      helm upgrade --version <chart version> --install my-release-scalardl scalar-labs/scalardl --namespace default -f scalardl-custom-values.yaml
   ```
 5. [Optional] Run the Helm commands on the bastion to install Scalar DL auditor on AKS.
   
    ```console
    # Load schema for Scalar DL auditor install with a release name `load-schema`
      helm upgrade --version <chart version> --install load-schema-audit scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml --set schemaLoading.schemaType=auditor
    
    # Install Scalar DL with a release name `my-release-scalardl`
      helm upgrade --version <chart version> --install my-release-scalardl-audit scalar-labs/scalardl-audit --namespace default -f scalardl-audit-custom-values.yaml
    ```

Note:

* The same commands can be used to upgrade the pods.
* Release name `my-release-scalardl` can be changed at your convenience.
* Release name `my-release-scalardl-audit` can be changed at your convenience.
* The `chart version` can be obtained from `helm search repo scalar-labs` output
* `helm ls -a` command can be used to list currently installed releases.
* You should confirm the load-schema deployment has been completed with `kubectl get pods -o wide` before installing Scalar DL.
* Follow the [Maintain Scalar DL Pods](./MaintainPods.md) for maintaining Scalar DL pods with Helm.

## Step 5. Monitor the cluster

It is critical to actively monitor the overall health and performance of a cluster running in production.
This section shows how to configure container insights for the AKS cluster, Container insights gives you performance visibility by collecting memory and processor metrics from controllers, nodes, and containers.
Container insights collects container logs also for log monitoring.
For more information on the container insights you can follow [official guide](https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview).

## Recommendations

* You should configure alerting for the AKS cluster on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-metric-alerts#enable-alert-rules)

### Steps

* Enable monitoring of Azure Kubernetes Service on the basis of [the official guide](https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-enable-existing-clusters).

## Step 6. Checklist for confirming Scalar DL deployments

After the Scalar DL deployment, you need to confirm that deployment has been completed successfully. This section will help you to confirm the deployment.

### Confirm Scalar DL deployment

* Make sure the schema is properly created in the underlying database service.

* You can check if the pods and the services are properly deployed by running the `kubectl get pods,services -o wide` command on the bastion.
    * You should confirm the status of all ledger and envoy pods are `Running`.
    * You should confirm the `EXTERNAL-IP` of Scalar DL envoy service is created.
    
    ```
    kubectl get pods,services -o wide
    NAME                                                     READY   STATUS      RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
    pod/load-schema-audit-schema-loading-rjd2z               0/1     Completed   0          11m     10.44.13.207   aks-agentpool-94561911-vmss000002      <none>           <none>
    pod/load-schema-schema-loading-bnkf5                     0/1     Completed   0          100m    10.44.12.17    aks-scalardlpool-94561911-vmss000000   <none>           <none>
    pod/my-release-scalardl-audit-auditor-75fdddb97d-6vdvb   1/1     Running     0          9m37s   10.44.12.12    aks-scalardlpool-94561911-vmss000000   <none>           <none>
    pod/my-release-scalardl-audit-auditor-75fdddb97d-hh95c   1/1     Running     0          9m37s   10.44.12.136   aks-scalardlpool-94561911-vmss000002   <none>           <none>
    pod/my-release-scalardl-audit-auditor-75fdddb97d-j7gv6   1/1     Running     0          9m37s   10.44.12.102   aks-scalardlpool-94561911-vmss000001   <none>           <none>
    pod/my-release-scalardl-audit-envoy-7488f87cb7-4vb92     1/1     Running     0          9m37s   10.44.12.114   aks-scalardlpool-94561911-vmss000002   <none>           <none>
    pod/my-release-scalardl-audit-envoy-7488f87cb7-g6mj9     1/1     Running     0          9m37s   10.44.12.22    aks-scalardlpool-94561911-vmss000000   <none>           <none>
    pod/my-release-scalardl-audit-envoy-7488f87cb7-lpkwm     1/1     Running     0          9m37s   10.44.12.61    aks-scalardlpool-94561911-vmss000001   <none>           <none>
    pod/my-release-scalardl-envoy-76f55dd48d-9lsw9           1/1     Running     0          43m     10.44.12.104   aks-scalardlpool-94561911-vmss000001   <none>           <none>
    pod/my-release-scalardl-envoy-76f55dd48d-n2bff           1/1     Running     0          43m     10.44.12.109   aks-scalardlpool-94561911-vmss000002   <none>           <none>
    pod/my-release-scalardl-envoy-76f55dd48d-sbvsj           1/1     Running     0          43m     10.44.12.40    aks-scalardlpool-94561911-vmss000000   <none>           <none>
    pod/my-release-scalardl-ledger-6564866b5d-886r4          1/1     Running     0          43m     10.44.12.93    aks-scalardlpool-94561911-vmss000001   <none>           <none>
    pod/my-release-scalardl-ledger-6564866b5d-8wx8t          1/1     Running     0          43m     10.44.12.18    aks-scalardlpool-94561911-vmss000000   <none>           <none>
    pod/my-release-scalardl-ledger-6564866b5d-q9xhk          1/1     Running     0          43m     10.44.12.144   aks-scalardlpool-94561911-vmss000002   <none>           <none>
  
    NAME                                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                           AGE     SELECTOR
    service/kubernetes                                   ClusterIP      10.0.0.1       <none>        443/TCP                           3h2m    <none>
    service/my-release-scalardl-audit-auditor-headless   ClusterIP      None           <none>        50051/TCP,50053/TCP,50052/TCP     9m37s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalardl-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalardl-audit-envoy              LoadBalancer   10.0.133.105   10.44.24.5    40051:32140/TCP,40052:30215/TCP   9m37s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalardl-audit-envoy-metrics      ClusterIP      10.0.245.41    <none>        9001/TCP                          9m37s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalardl-audit-metrics            ClusterIP      10.0.7.153     <none>        8080/TCP                          9m37s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalardl-audit,app.kubernetes.io/name=scalardl-audit
    service/my-release-scalardl-envoy                    LoadBalancer   10.0.160.101   10.44.24.4    50051:32326/TCP,50052:30093/TCP   43m     app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
    service/my-release-scalardl-envoy-metrics            ClusterIP      10.0.15.90     <none>        9001/TCP                          43m     app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
    service/my-release-scalardl-ledger-headless          ClusterIP      None           <none>        50051/TCP,50053/TCP,50052/TCP     43m     app.kubernetes.io/app=ledger,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
    service/my-release-scalardl-metrics                  ClusterIP      10.0.42.200    <none>        8080/TCP                          43m     app.kubernetes.io/app=ledger,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl 
   ```

Note:

* Audit pods and services will be available after the deployment of auditor services. 

### Confirm AKS cluster monitoring

* Confirm the Cluster insights on the basis of [Container insights](https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview#how-do-i-access-this-feature) document.

### Confirm database monitoring

* Confirm the monitoring of Azure Cosmos DB on the basis of [Monitor Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db) document.

## Clean up the resources

When you need to remove the resources that you have created, remove the resources in the following order.

* Scalar DL
* AKS cluster
* Cosmos DB account
* Bastion server
* Virtual network
* Resource group

### Uninstall Scalar DL

You can uninstall Scalar DL with the following Helm commands:

   ```console
    # Uninstall loaded schema with a release name 'load-schema'
      helm uninstall load-schema

    # Uninstall Scalar DL with a release name 'my-release-scalardl'
      helm uninstall my-release-scalardl

    # Uninstall Scalar DL with a release name 'my-release-scalardl-audit'
      helm uninstall my-release-scalardl-audit
   ```
### Clean up the other resources

You can remove the other resources via the web console or the command-line interface.

For more detail about the command-line interface, please take a look at [the official document]( https://docs.microsoft.com/en-us/cli/azure/).
