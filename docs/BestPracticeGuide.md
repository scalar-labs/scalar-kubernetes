# Recommended Practices of Operation with Scalar Kubernetes

This guide shows recommended practices of operation with our Scalar Kubernetes.

## Use the same versioned orchestration tool

Different versions could produce different results so it is recommended to use the same version if possible.
If the tool needs to be upgraded for some reason, please review the change with extra care.

## Use the same version for kubectl and kubernetes.

Always keep the same version between kubectl and kubernetes to ensure full compatibility.

## Don't `helm delete` or `kubectl delete` for nodes

`helm delete` should not be done especially in a production environment since it removes completely the application.
`kubectl delete` for nodes should also be avoided since it will remove a specified node from a Kubernetes cluster but it might not be noticeable by Cloud providers.
