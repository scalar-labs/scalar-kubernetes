# Cloud Privileges for scalar-kubernetes

## Azure

To interact with Azure APIs, an AKS cluster requires an Azure Active Directory (AD) service principal, which is used to create and manage other Azure resources such as an Azure load balancer.

In scalar-kubernetes, the terraform module is the one who creates a service principal and assigns permissions to it and deletes it, so we recommend assigning `User Access Administrator` to operators of Terraform.
## AWS
