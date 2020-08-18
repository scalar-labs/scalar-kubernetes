# Recommended Practices of Operation with Scalar Kubernetes

This guide shows recommended practices of operation with our Scalar Kubernetes.

## Use the same versioned orchestration tool

Different versions could produce different results so it is recommended to use the same version if possible.
If the tool needs to be upgraded for some reason, please review the change with extra care.

## Use the same kubectl than kubernetes version

Always keep the same version between kubectl and kubernetes to ensure full compatibility.

## Anything that are not recommended

- Helm delete command, avoid using helm delete <release_name> for Scalar DL as it will stop the production.
- Kubectl delete nodes command, as I will remove the node from kubernetes but not the cloud providers
