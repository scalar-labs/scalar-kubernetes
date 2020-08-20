# Recommended Practices of Operation with Scalar Kubernetes

This guide shows recommended practices of operation with our Scalar Kubernetes.

## Use the same versioned orchestration tool

Different versions could produce different results so it is recommended to use the same version if possible.
If the tool needs to be upgraded for some reason, please review the change with extra care.

## Use the same kubectl than kubernetes version

Always keep the same version between kubectl and kubernetes to ensure full compatibility.

## Don't `helm delete` or `kubectl delete`

helm delete should not be done especially in production environment since it remove completely the application.
kubectl delete node should be avoided as well since it will remove a specified node from Kubernetes cluster but it might not be noticeable by Cloud providers.
