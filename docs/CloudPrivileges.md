# Cloud Privileges for scalar-k8s

To interact with Azure APIs, an AKS cluster requires an Azure Active Directory (AD) service principal. A service principal is needed to dynamically create and manage other Azure resources such as an Azure load balancer.

In order to deploy AKS, the terraform user should have the permission to:

* Create service principal
* Give and remove “rights” to service principal
* Delete service principal

We recommend to add to the terraform user the azure role `User Access Administrator`.
