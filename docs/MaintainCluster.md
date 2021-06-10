# Maintain the cluster

Scalar DL provides customization based on your requirements. You can customize the following features in the Scalar DL helm charts based on your convenience.

## Increase the number of Envoy Pods

You can increase the number of envoy pods based on your requirements. The following steps will help you to achieve it:

In `scalardl-custom-values.yaml`, you can update the number of `replicaCount` to the desired number of pod

```yaml
envoy:
  replicaCount: 6
```

The number of deployable pods depends on the number of available nodes. So, you may need to increase the number of nodes from the AWS console.

## Increase the resource of Envoy Pods

You can increase the resource of envoy pods based on your requirements. The following steps will help you to achieve it:

In `scalardl-custom-values.yaml`, you can update resource as follow

```yaml
envoy:
  resources:
    requests:
      cpu: 400m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 328Mi
```
More information can be found in [the official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)

## Expose Envoy endpoint to public

Scalar DL supports both public and private endpoints. 
The public endpoint allows you to access Scalar DL and deploy applications from outside the network. 
The private endpoint allows you to access Scalar DL and deploy applications only from within your network or you can connect another VPC to the Scalar DL network using VPC peering.

In `scalardl-custom-values.yaml`, you can update the `aws-load-balancer-internal` as false to expose `Envoy`

```yaml
envoy:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-internal: "false"
```

## Increase the number of Ledger Pods

You can increase the number of ledger pods based on your requirements. The following steps will help you to achieve it:

In `scalardl-custom-values.yaml`, you can update `replicaCount` to the desired number of pods.

```yaml
ledger:
  replicaCount: 6
```

The number of deployable pods depends on the number of available nodes. You may need to increase the number of nodes from the AWS console.

## Increase the resource of Ledger Pods

You can increase the resource of ledger pods based on your requirements. The following steps will help you to achieve it:

In `scalardl-custom-values.yaml`, you can update resource as follow

```yaml
ledger:
  resources:
    requests:
      cpu: 1500m
      memory: 2Gi
    limits:
      cpu: 1600m
      memory: 4Gi
```
More information can be found in the [official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)
