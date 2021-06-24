# Cloud Permissions For Manual Scalar DL Environment Creation 

This guide explains how to assign required permissions for the users to manually create cloud resources for deploying Scalar DL on Azure and must be  
used with Scalar DL [manual deployment guide for Azure](./ManualDeploymentGuideScalarDLOnAzure.md).

From the security perspective, it is better to give users limited permissions to protect the environment from unwanted activities.

## Azure

The following JSON is a custom role that allows users to manage Azure cloud resources from the Azure portal or from command line tools for deploying Scalar DL.
Please note that it is sufficient but not necessary since, it can/should be further restricted.

In Azure Portal, you can create the role in the Subscriptions section. Choose your subscription and select Access control (IAM) from the menu, then click `+Add` and select `Add custom role`. 
Once the role is created, you can assign it to a user or a group from `Add role assignment` in the `+Add` menu.

Please replace your subscription ID in the `assignableScopes` array. You can give `roleName` and `description` as per your convenience.

```json
{   
 "properties": {
        "roleName": "Scalar DL permissions",
        "description": "Permissions to deploy Scalar DL on AKS",
        "assignableScopes": [
            "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        ],
        "permissions": [
            {
                "actions": [
                    "Microsoft.Authorization/roleAssignments/*",
                    "Microsoft.Compute/availabilitySets/*",
                    "Microsoft.Compute/disks/*",
                    "Microsoft.Compute/virtualMachines/*",
                    "Microsoft.Network/loadBalancers/*",
                    "Microsoft.Network/networkInterfaces/*",
                    "Microsoft.Network/networkSecurityGroups/*",
                    "Microsoft.Network/publicIPAddresses/*",
                    "Microsoft.Network/virtualNetworks/*",
                    "Microsoft.Resources/deployments/*",
                    "Microsoft.Resources/subscriptions/resourceGroups/*",
                    "Microsoft.DocumentDb/databaseAccounts/*",
                    "Microsoft.ContainerService/managedClusters/*",
                    "Microsoft.OperationsManagement/solutions/*",
                    "Microsoft.operationalInsights/workspaces/*"
                ],
                "notActions": [],
                "dataActions": [],
                "notDataActions": []
            }
        ]
    }
}
```

Note:

Following are the permissions for each assignment

* `Microsoft.Authorization/roleAssignments/*` : To assign roles for the resources.
* `Microsoft.Compute/availabilitySets/*` : To create and manage availabilitySets.
* `Microsoft.Compute/disks/*` : To create and manage disks for virtual machines.
* `Microsoft.Network/loadBalancers/*` : To create and manage Load balancers.
* `Microsoft.Network/networkInterfaces/*` : To create and manage network interfaces
* `Microsoft.Network/networkSecurityGroups/*` : To create and manage security groups
* `Microsoft.Network/publicIPAddresses/*` : To create and manage public IP address.
* `Microsoft.Network/virtualNetworks/*` : To create and manage virtual network.
* `Microsoft.Resources/deployments/*` : To validate the Azure deployment template for creating the resources.
* `Microsoft.Resources/subscriptions/resourceGroups/*` : To create and manage resource groups.
* `Microsoft.ContainerService/managedClusters/*` : To create and manage the AKS cluster.
* `Microsoft.OperationsManagement/solutions/*`: To manage the Azure container insights.
* `Microsoft.operationalInsights/workspaces/*` : To manage Azure logs.

You can replace the permission for accessing the databases as below in the JSON as per the database you use.

| Database | Permission                               | Description                     | 
|----------|------------------------------------------|---------------------------------|
| Cosmos DB| `Microsoft.DocumentDb/databaseAccounts/*`|  To create and manage Cosmos DB |

### Create Permissions for AKS cluster

To interact with Azure APIs, an AKS cluster requires either an Azure Active Directory (AD) service principal or a managed identity. 
A service principal is needed for the AKS cluster to access dynamically create and manage other Azure resources.

To create a service principal for the AKS cluster ask an account with the `Owner` role to create a service principal on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli).
Also, add `Directory Reader` permission for your user on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/active-directory/roles/manage-roles-portal) to allow the user access to the service principal.
