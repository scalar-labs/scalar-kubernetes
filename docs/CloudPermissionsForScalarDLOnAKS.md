# Cloud Permissions for Creating Scalar DL on Azure AKS

This guide explains what permissions are required to deploy Scalar DL on Azure AKS.
This guide assumes that you create the environment on the basis of [manual deployment guide for Azure](./ManualDeploymentGuideScalarDLOnAzure.md).
From the security perspective, it is better to give users limited permissions to protect the environment from unwanted activities.

## Assign permissions to users who create resources for Scalar DL

The following JSON is a custom role that specifies the required permissions that allow users to create Azure cloud resources (either from Azure portal or the command line) to deploy Scalar DL. 
Please replace your subscription ID in the `assignableScopes` array. 
It is recommended to put `roleName` and `description` to specify what the permissions for, however, they are not required.
Note that the permissions are sufficient but not necessary.

In Azure Portal, you can create the role in the `Subscriptions` section. Choose your subscription and select Access control (IAM) from the menu, then click `+Add` and select `Add custom role`. 
Once the role is created, you can assign it to a user or a group from `Add role assignment` in the `+Add` menu.


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

Note that `Microsoft.DocumentDb/databaseAccounts/*` is the one for Cosmos DB, so
it must be replaced if you want to use another database.

Please check the following to understand what each assignment means, and add or remove on the basis of your need.

* `Microsoft.Authorization/roleAssignments/*` : To assign roles for the resources.
* `Microsoft.Compute/availabilitySets/*` : To create and manage availabilitysets.
* `Microsoft.Compute/disks/*` : To create and manage disks for virtual machines.
* `Microsoft.Network/loadBalancers/*` : To create and manage load balancers.
* `Microsoft.Network/networkInterfaces/*` : To create and manage network interfaces.
* `Microsoft.Network/networkSecurityGroups/*` : To create and manage security groups.
* `Microsoft.Network/publicIPAddresses/*` : To create and manage public IP addresses.
* `Microsoft.Network/virtualNetworks/*` : To create and manage virtual networks.
* `Microsoft.Resources/deployments/*` : To validate the Azure deployment template for creating the resources.
* `Microsoft.Resources/subscriptions/resourceGroups/*` : To create and manage resource groups.
* `Microsoft.DocumentDb/databaseAccounts/*` : To create and manage Cosmos DB.
* `Microsoft.ContainerService/managedClusters/*` : To create and manage the AKS clusters.
* `Microsoft.OperationsManagement/solutions/*`: To manage the Azure container insights.
* `Microsoft.operationalInsights/workspaces/*` : To manage Azure logs.

## Assign permissions to an AKS cluster to interact with the resources

An AKS cluster itself also needs to create and manage Azure resources by using Azure APIs.
To do that, the AKS cluster requires either an Azure Active Directory (AD) service principal or a managed identity. 

To create a service principal for an AKS cluster, ask an account with the `Owner` role to create a service principal on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli).
Also, add `Directory Reader` role to a user that creates the cluster on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/active-directory/roles/manage-roles-portal) to allow the user access to the service principal.
