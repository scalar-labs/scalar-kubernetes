# Manual steps for creating Scalar DL environment in Azure

This document contains manual steps for creating a Scalar DL environment in the Azure cloud. 

## What we create

![image](images/azure-diagram.png)

Following are the resources to be created using this document.

* Resource group
* Azure Virtual network
* Bastion instance with a public IP.
* A managed database service.
    * Cosmos DB account
* Kubernetes Cluster 
* Azure container insights

## Prerequisites

Before creating the environment, user should have at least minimum permissions for creating and managing the Azure cloud resources for Scalar DL deployment. 
From a security perspective, it is better to give user's limited permissions to protect the environment from unwanted activities. 
You can skip the following steps If the user has an [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner) or [Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) role in Azure.

You can use the following steps to create and assign a custom role to the user. User should have `Privileged Role Administrator` or `Global Administrator` to do the following 

* Select [Subscriptions](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade) from Azure portal
* Select **Subscription name**
* Select **Access control (IAM)**
* Click **Add**
* Select **Add custom role**
    * On the Basics page, configure the following options
        * Enter a **custom role name** 
        * Enter a **Description**
        * Select **Start from scratch**
        * Click **Next**
    * On the Assignable scopes page, configure the following options
        * Select your **Subscription**
        * Click **Next**
    * On the JSON page
        * Click **Edit**
        * Paste the permissions section from [JSON](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/CloudPermissionsForScalarDLOnAKS.md#assign-permissions-to-users-who-create-resources-for-scalar-dl)
        * Click **Next** 
    * On **Review+Create** page
        * Click **Create**
        * Click **OK**
* On the Access control IAM page in subscription, configure the following options
    * Click **Add**
    * Click **Add role assignment**, enter the following details in the blade that can be seen on the right side
        * Select created custom role from **Role**
        * Select User, group or service principal from **Assign access to**
        * Select desired username from **Select** 
        * Click **Save**

Add _Directory reader_ permission for the user to access the service principal
* Select [Azure Active Directory](https://aad.portal.azure.com/) from Azure portal
* Select **Roles and administrators** from left navigation
* Select **Directory readers** role
* Click **Add assignments**
    * Search username and click **Add** 
   
Create service principal for AKS cluster using the following steps

* Manually create service principal using following command
    ```console
    $ az ad sp create-for-rbac --skip-assignment --name myAKSClusterServicePrincipal
    ```
## Create resource group

Create a resource group to place the cloud resources of your Scalar DL environment. You can use the following steps to create a resource group

* Select [Resource groups](https://portal.azure.com/#blade/HubsExtension/BrowseResourceGroups) from Azure Portal.
* Click **Create**
* On the Basics page, configure the following options
    * Select your **Subscription**
    * Enter **Resource group** name
    * Select **Region**
    * Click **Review+Create**
    * Click **Create**
    
## Create virtual network

A virtual network is the fundamental building block for your private network. Azure resources such as virtual machines, Kubernetes clusters must be created upon the virtual network. 
Create a virtual network for your Scalar DL environment using the following steps

* Select [Virtual networks](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Network%2FvirtualNetworks) from Azure portal
* Click **Create**
* On the Basics page, configure the following options
    * Select your **Subscription**
    * Select the **Resource group**
    * Enter **Name**
    * Select **Region**
    * Click **Next: IP Addresses**
* On the IP Addresses page, enter the following values for the virtual network.
    * Enter **IPv4 Address space** as _10.42.0.0/16_ for virtual network.
    * Click **Add subnet** and add the following subnets
        * Enter **Subnet name** as _public_ and **subnet address range** as _10.42.0.0/24_ then click **Add**
        * Enter **Subnet name** as _k8s_node_pod_ and **subnet address range** as _10.42.40.0/22_ then click **Add**
        * Enter **Subnet name** as _k8s_ingress_ and **subnet address range** as _10.42.44.0/22_ then click **Add**
    * Click **Review+create**
    * Click **Create**

## Create Cosmos DB

To use Cosmos DB as the database for Scalar DL. Use the following steps to create a Cosmos DB account for your Scalar DL environment

* Select [Cosmos DB](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.DocumentDb%2FdatabaseAccounts) from Azure portal
* Click **Create**
* Click **Create** in _Core (SQL) - Recommended_
* Select your **Subscription**
* Select your **Resource group**
* Enter **Account Name**
* Select **Location**
* Select **Capacity mode** as _Provisioned throughput_
* Click **Review+Create**
* Click **Create**
* Click **Go to resource** (option available after Cosmos DB account creation)  
* Select **Default consistency** from left navigation
    * Select _STRONG_ and click **Save** 

## Create Bastion

You must have a bastion server to access the private AKS cluster. You can use the following steps to create a bastion server.
 
* Select [Virtual machines](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Compute%2FVirtualMachines) from Azure portal
* Click **Create**
* Select **Virtual machine**
* On the Basics page, configure the following options
    * Select an Azure **Subscription**
    * Select your **Resource group**
    * Enter **Virtual machine name**
    * Select **Region** 
    * Select any of the following availability options in the dropdown menu, select any of the following availability options in the dropdown menu, You can select the _No infrastructure redundancy required_ option if you don't want any.
        * Availability set: Select created availability set from dropdown menu
        * Availability zone: Select an availability zone 1 or 2 or 3
    * Select Image _CentOS-based 7.9 - Gen 1_
    * Select **Size** as _Standard_B1s_ from dropdown menu
    * Select authentication type as SSH public key(generate an SSH key to access the server) or password(can use username and password to SSH access the server).
    * Enter **Username** as centos
    * If you are using **Password** for authentication type.
        * Enter **Password**
        * Enter **Confirm password**
    * If you are using **SSH public key** for authentication type.
        * Select **Generate new key pair**
        * Select **Use existing public key** and upload already generated public key in SSH public key box.
    * Select **Public inbound ports** as _Allow selected ports_.
    * **Select inbound ports** as _SSH (22)_ from the dropdown menu.
* On the Networking page, select virtual network settings
    * Select your **virtual network** from drop-down menu
    * Select subnet **public**
    * Click **Review+Create**
    * Click **Create** 

## Create Kubernetes Cluster

This section shows how to configure a Kubernetes service for Scalar DL deployment.

* Select [Kubernetes services](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ContainerService%2FmanagedClusters) from Azure portal
* Click **Create**
* Select **Create a Kubernetes cluster**
* On the Basics page, configure the following options
    * Select your **Subscription**
    * Select your **Resource group**
    * Enter **Kubernetes Cluster name**
    * Select **Region**
    * Select **Availability zones** from drop down if you want to create in multiple availability zones
    * Select **Kubernetes version** _1.19.11_ from dropdown
    * Select **Node size** as _Standard_D2s_v3_
    * Select **Scale method** as _Autoscale_
    * Select Node count range as min: 3 and max: 6
    * Click **Next: Node pools**
* On the Node Pools page, configure the following options
    * Click **Add node pool** 
    * On Add a node pool page, configure the following options
        * Enter **Node pool name** as _scalardlpool_
        * Select **Mode** as _User_
        * Select **OS type** as _Linux_
        * Select **Availability zones** from drop-down
        * Select **Node size** as _D2s_v3_
        * Select **Node count** range as min: 3 and max: 6
        * Enter **Max pods per node** as 10
        * Click **Add**
        * Click **Next: Authentication**
* On the Authentication page, configure the following options
    * Select _Service principal_ as **Authentication method**
    * Enter **Service principal client ID** (Use appId of service principal)
    * Enter **Service principal client secret** (Use password of service principal)
    * Select _Enabled_ for **Role-based access control**
    * Select **Next: Networking**
* On the Networking page, configure the following options
    * Select _Azure CNI_ in **Network configuration**
    * Select your **Virtual network**
    * Select _k8s_node_pod_ as **Cluster Subnet**
    * Select **Enable private cluster** if you want to create AKS cluster as private
    * Select **Next:Integrations**
* On the Integrations page, configure the following options
    * Select _Enabled_ for **Container monitoring**
    * Click **Review+Create**         
    * Click **Create**

Add `network contributor` role for the `k8s_ingress` subnet to create the envoy load balancer

* Select your **Virtual network**
* Select **Subnets** from left navigation
* Select _k8s_ingress_ subnet and Click on **Manage users**
* On the Access control page
    * Click **Role assignments**
    * Click **Add**
    * Select **Add role assignment**
        * Select _Network Contributor_ as Role
        * Select _User, group or service principal_ in **Assign access to** option
        * Type the name of the service principal used for creating the AKS cluster and **Select**  
        * Click **Save**
        
## Install Scalar DL

After creating a Kubernetes cluster next step is to deploy Scalar DL into the AKS cluster. 
This section shows how to install Scalar DL to the AKS cluster with [Helm charts](https://github.com/scalar-labs/helm-charts).

### Prerequisites

Install the following tools on your machine(bastion required for private AKS cluster) to access the Kubernetes cluster.

* You must have the authority to pull `scalar-ledger` and `scalardl-schema-loader` container images.
* Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) to create kubeconfig to access the Kubernetes cluster.
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/) to manage the Kubernetes cluster.
* Configure kubectl to connect to your Kubernetes cluster using the `az aks get-credentials` command
    ```console
     $ az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
* Install [Helm](https://helm.sh/docs/intro/install/) to deploy Scalar DL Helm charts to the Kubernetes cluster. Helm version 3.5 or latest is required.

### Steps

* Create the docker-registry secret for pulling the Scalar DL images from the GitHub Packages.

    ```console
    $ kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token>
    ```

* Download the following Scalar DL configuration files from [the scalar-kubernetes repository](https://github.com/scalar-labs/scalar-kubernetes/tree/master/conf). Note that they are going to be versioned in the future, so you might want to change the branch to use a proper version.
    * scalardl-custom-values.yaml
    * schema-loading-custom-values.yaml

* Update the database configuration: 

For `schema-loading-custom-values.yaml` update the following configuration 

```yaml
schemaLoading:
  database: cosmos
  contactPoints: https://example-k8s-azure-b8ci1si-cosmosdb.documents.azure.com:443/
  password: <PRIMARY_MASTER_KEY>
  cosmosBaseResourceUnit: "400"
```
For `scalardl-custom-values.yaml` update the following configuration

```yaml
scalarLedgerConfiguration:
    dbContactPoints: https://example-k8s-azure-b8ci1si-cosmosdb.documents.azure.com:443/
    dbPassword: <PRIMARY_MASTER_KEY>
    dbStorage: cosmos
```
 
* Run the Helm commands to install Scalar DL on AKS.
    
   ```console
    # Add Helm charts 
    $ helm repo add scalar-labs https://scalar-labs.github.io/helm-charts
    
    # List the Scalar charts.
    $ helm search repo scalar-labs
    
    # Load Schema for Scalar DL install with a release name `load-schema`
    $ helm upgrade --install load-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml
    
    # Install Scalar DL with a release name `my-release-scalardl`
    $ helm upgrade --install my-release-scalardl scalar-labs/scalardl --namespace default -f scalardl-custom-values.yaml
   ```
Note:
* The same commands can be used to upgrade the pods.
* Release name `my-release-scalardl` can be changed as per your convenience.
* `helm ls -a` command can be used to list currently installed releases.
* You should confirm the load-schema deployment has been completed with `kubectl get pods` before installing Scalar DL.  
  
### Confirm Scalar DL deployment

* You can check if the pods and the services are properly deployed by running the kubectl get po,svc,endpoints -o wide commands.
    * You should confirm the status of all ledger and envoy pods are `Running`.
    * You should confirm the `EXTERNAL-IP` of Scalar DL envoy service is created.
   
   ```console
    $ kubectl get pods,services -o wide

    NAME                                              READY   STATUS      RESTARTS   AGE   IP            NODE                                   NOMINATED NODE   READINESS GATES
    pod/load-schema-schema-loading-kkwm2              0/1     Completed   0          26m   10.42.41.70   aks-agentpool-40363514-vmss000002      <none>           <none>
    pod/my-release-scalardl-envoy-59c7594b45-2vtdw    1/1     Running     0          16m   10.42.40.27   aks-scalardlpool-40363514-vmss000002   <none>           <none>
    pod/my-release-scalardl-envoy-59c7594b45-dbblc    1/1     Running     0          16m   10.42.40.16   aks-scalardlpool-40363514-vmss000001   <none>           <none>
    pod/my-release-scalardl-envoy-59c7594b45-sbnt9    1/1     Running     0          16m   10.42.40.11   aks-scalardlpool-40363514-vmss000000   <none>           <none>
    pod/my-release-scalardl-ledger-6556466cd5-7gbgz   1/1     Running     0          16m   10.42.40.31   aks-scalardlpool-40363514-vmss000002   <none>           <none>
    pod/my-release-scalardl-ledger-6556466cd5-l947l   1/1     Running     0          16m   10.42.40.22   aks-scalardlpool-40363514-vmss000001   <none>           <none>
    pod/my-release-scalardl-ledger-6556466cd5-qvb8b   1/1     Running     0          16m   10.42.40.12   aks-scalardlpool-40363514-vmss000000   <none>           <none>

    NAME                                          TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                           AGE   SELECTOR
    service/kubernetes                            ClusterIP      10.0.0.1       <none>        443/TCP                           81m   <none>
    service/my-release-scalardl-envoy             LoadBalancer   10.0.235.249   10.42.44.4    50051:31821/TCP,50052:32529/TCP   16m   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
    service/my-release-scalardl-envoy-metrics     ClusterIP      10.0.49.178    <none>        9001/TCP                          16m   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
    service/my-release-scalardl-ledger-headless   ClusterIP      None           <none>        50051/TCP,50053/TCP,50052/TCP     16m   app.kubernetes.io/app=ledger,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
   ``` 
  
## Clean up the resources

When you need to remove the resources that you have created, remove the resources in the following order

* Scalar DL 
* AKS cluster
* Cosmos DB account
* Bastion server
* Virtual Network
* Resource group

### Uninstall Scalar DL

You can uninstall Scalar DL with the following Helm commands:

   ```console
    # Uninstall loaded schema with a release name 'load-schema'
    $ helm uninstall load-schema

    # Uninstall Scalar DL with a release name 'my-release-scalardl'
    $ helm uninstall my-release-scalardl
   ```

### Clean up the other resources

To Remove the **AKS cluster** you can use the following steps
* Select [Kubernetes services](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ContainerService%2FmanagedClusters) from Azure portal
* Select your AKS cluster
* Click on **Delete**
* On the pop up click **Yes**

To Remove the **Cosmos DB** account you can use the following steps
* Select [Cosmos DB](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.DocumentDb%2FdatabaseAccounts) from Azure portal
* Select your Cosmos DB account
* Select **Delete Account** 
    * Enter Cosmos DB account name in **Confirm the Account Name** box
    * Click **Delete**  

To Remove the **Virtual machine** you can use the following steps
* Select [Virtual machines](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Compute%2FVirtualMachines) from Azure portal
* Select your Virtual machine
    * Select **Delete**
    * Select **OK** on the pop up

To Remove **Virtual Network** and **Resource group** you can use the following steps
* Select [Resource groups](https://portal.azure.com/#blade/HubsExtension/BrowseResourceGroups) from Azure portal
* Select your Resource group.
    * Select **Delete resource group**.
    * Enter resource group name in **TYPE THE RESOURCE GROUP NAME** box.
    * Click Delete.               