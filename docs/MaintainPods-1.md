# Maintain Scalar DL pods

This document shows how to maintain Scalar DL pods.

## Adjust the number of pods

You can adjust the number of pods in Ledger, Auditor and Envoy based on your requirements by updating the number of `replicaCount` as shown below to the desired number respectively in `scalardl-custom-values.yaml` and `scalardl-audit-custom-values.yaml`.


Ledger
```yaml
ledger:
  replicaCount: 6
```

Auditor
```yaml
auditor:
  replicaCount: 6
```

Envoy
```yaml
envoy:
  replicaCount: 6
```

Note that the number of deployable pods depends on the number of available nodes, so you may need to increase the number of nodes.

## Adjust the resource of pods

You can adjust the resource of Ledger, Auditor and Envoy pods based on your requirements by updating the following parts in `scalardl-custom-values.yaml` and `scalardl-audit-custom-values.yaml`.

Ledger
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

Auditor
```yaml
auditor:
  resources:
    requests:
      cpu: 1500m
      memory: 2Gi
    limits:
      cpu: 1600m
      memory: 4Gi
```

Envoy
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

More information can be found in [the official document](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container)

## Expose Envoy endpoint to public

Scalar DL supports both public and private endpoints.
A public endpoint allows you to access Scalar DL and deploy applications from outside the network.
A private endpoint allows you to access Scalar DL and deploy applications only from the same network as a Kubernetes cluster.

You can change the setting by updating the following annotation (`aws-load-balancer-internal` for AWS and `azure-load-balancer-internal` for Azure) In `scalardl-custom-values.yaml`,

```yaml
envoy:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
      service.beta.kubernetes.io/aws-load-balancer-internal: "true"
```