# Restricting cloud privileges for deploying Scalar DL

This guide explains how to restrict privileges for deploying Scalar DL on Azure.

In general from security perspective, it is better to assign restricted privileges to users not to make them able to do operations that they are not supposed to do.

## Azure

The following JSON is a custom role that allow users to manage resources for Scalar DL. This is sufficient but not necessary.

In Azure Portal, you can create the role in Subscriptions section. Choose your subscription and select Access control (IAM) from the menu, then click `+Add` and select `Add custom role`. 
Once the role is created, you can assign it to a user or a group from `Add role assignment` in the `+Add` menu.

Please keep your subscription ID in the `assignableScopes` array. You can give `rolename` and `description` as per your convenience.

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

### A Role for creating AKS cluster

To interact with Azure APIs, an AKS cluster requires either an Azure Active Directory (AD) service principal or a managed identity.
To create service principal for the AKS cluster ask an account with `Owner` role to create a service principal on the basis of [Azure official guide](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli). 
Also, add `Directory Reader` permission for your user on the basis of [Azure official guide]( https://docs.microsoft.com/en-us/azure/active-directory/roles/manage-roles-portal).
