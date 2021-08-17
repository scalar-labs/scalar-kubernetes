# Example steps to Deploy Scalar DL on Azure

This guide assumes that you create the environment on the basis of [manual deployment guide for Azure](./ManualDeploymentGuideScalarDLOnAzure.md).
This document contains example steps for creating a Scalar DL environment in the Azure cloud.

## Prerequisites

You can skip the following steps if the user who creates the resources has an [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner) or [User Access Administrator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator) role in Azure.
The User with `Privileged Role Administrator` or `Global Administrator` permission can use the following steps to create and assign a custom role with minimum permissions to the user who creates the resources in Azure cloud.

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
        * Paste the permissions section from [JSON](./CloudPermissionsForScalarDLOnAKS.md)
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
* Select [Azure Active Directory](https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview) from Azure portal
* Select **Roles and administrators** from left navigation
* Select **Directory readers** role
* Click **Add assignments**
    * Search username and click **Add**
   
Create service principal for AKS cluster using the following steps

* Manually create service principal using following command
    ```console
    az ad sp create-for-rbac --skip-assignment --name myAKSClusterServicePrincipal
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

Create a virtual network based on the [requirements](./ManualDeploymentGuideScalarDLOnAzure.md#step-1-configure-your-network) for your Scalar DL environment using the following steps

* Select [Virtual networks](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Network%2FvirtualNetworks) from Azure portal
* Click **Create**
* On the Basics page, configure the following options
    * Select your **Subscription**
    * Select the **Resource group**
    * Enter **Name**
    * Select **Region**
    * Click **Next: IP Addresses**
* On the IP Addresses page, enter the following values for the virtual network.
    * Update the default **IPv4 Address space** with _10.42.0.0/16_ for virtual network.
    * Click **Add subnet** and add the following subnets
        * Enter **Subnet name** as _public_ and **subnet address range** as _10.42.0.0/24_ then click **Add**
        * Enter **Subnet name** as _k8s_node_pod_ and **subnet address range** as _10.42.40.0/22_ then click **Add**
        * Enter **Subnet name** as _k8s_ingress_ and **subnet address range** as _10.42.44.0/22_ then click **Add**
    * Click **Review+create**
    * Click **Create**

## Create Cosmos DB

You can use following steps to create Cosmos DB account based on the basis of [requirements](./SetupAzureDatabase.md#cosmos-db)

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
    * Select appropriate `CentOS-based` image (example: _CentOS-based 7.9 - Gen 2_)
    * Select **Size** as _Standard_B1s_ from dropdown menu
    * Select authentication type as SSH public key(generate an SSH key to access the server) or password(can use username and password to SSH access the server).
    * Enter **Username** as centos
    * if you want to create a new key pair, select **Generate new key pair**.
    * if you want to use an existing key pair, select **Use existing public key** and upload already generated public key in SSH public key box.
    * Select **Public inbound ports** as _Allow selected ports_.
    * **Select inbound ports** as _SSH (22)_ from the dropdown menu.
* On the Networking page, select virtual network settings
    * Select your **virtual network** from drop-down menu
    * Select subnet **public**
    * Click **Review+Create**
    * Click **Create**

## Create Kubernetes Cluster

You can use the following steps to configure Kubernetes cluster based on the [requirements](./ManualDeploymentGuideScalarDLOnAzure.md#step-3-configure-aks)

* Select [Kubernetes services](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ContainerService%2FmanagedClusters) from Azure portal
* Click **Create**
* Select **Create a Kubernetes cluster**
* On the Basics page, configure the following options
    * Select your **Subscription**
    * Select your **Resource group**
    * Enter **Kubernetes Cluster name**
    * Select **Region**
    * Select **Availability zones** from drop down if you want to create in multiple availability zones
    * Select **Kubernetes version** _1.19_ from dropdown
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
        * Select **Scale method** as _Autoscale_
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

Assign `network contributor` role to service principal for creating the envoy load balancer on `k8s_ingress` subnet

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
        
## Setup Bastion

Follow the _Prerequisites_ of _Configure AKS_ in the [manual deployment guide for Azure](./ManualDeploymentGuideScalarDLOnAzure.md#prerequisites-1)

After completing the above specified prerequisites, configure the kubectl to your Kubernetes cluster using the `az aks get-credentials` command. 

```console
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

## Install Scalar DL

Install Scalar DL to the AKS cluster on the basis of [manual deployment guide for Azure](./ManualDeploymentGuideScalarDLOnAzure.md#step-4-install-scalar-dl)

### Confirm Scalar DL deployment

Confirm the Scalar DL deployment on the basis of [manual deployment guide for Azure](./ManualDeploymentGuideScalarDLOnAzure.md#confirm-scalar-dl-deployment)

## Clean up the resources

Remove the Scalar DL installation on the basis of [manual deployment guide for Azure](./ManualDeploymentGuideScalarDLOnAzure.md#uninstall-scalar-dl)

Clean up other resources using following steps

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
      