# Assign Required Cloud Permissions For Deploying Scalar DL

This guide explains how to assign required permissions for the users for deploying Scalar DL on Azure.

From the security perspective, it is better to give users limited privileges to protect the environment from unwanted activities.

## Azure

The following JSON is a custom role that allows users to manage Azure cloud resources for Scalar DL. These are the minimum permissions for creating a Scalar DL environment on the Azure cloud.

In Azure Portal, you can create the role in the Subscriptions section. Choose your subscription and select Access control (IAM) from the menu, then click `+Add` and select `Add custom role`. 
Once the role is created, you can assign it to a user or a group from `Add role assignment` in the `+Add` menu.

Please replace your subscription ID in the `assignableScopes` array. You can give `roleName` and `description` at your convenience.

```json
{   
 "properties": {
        "roleName": "manual-guide-test",
        "description": "manual-guide-test",
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

### Create Privileges for AKS cluster

To interact with Azure APIs, an AKS cluster requires either an Azure Active Directory (AD) service principal or a managed identity. 
A service principal is needed for the AKS cluster to access dynamically create and manage other Azure resources.

To create a service principal for the AKS cluster ask an account with the `Owner` role to create a service principal on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli).
Also, add `Directory Reader` permission for your user on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/active-directory/roles/manage-roles-portal) to allow the user access to the service principal.
