# Envoy Alerts

## EnvoyDeploymentHasNoReplicas

This is the most critical alert and indicates that the Envoy cluster is not able to process requests. This alert should be handled with the highest priority.

### Example Alert

#### Firing

```console
[FIRING:1]
Alert: scalar-envoy: has no replicas. - critical
 Description: deployment scalar-envoy has 0 replicas
 Details:
  • alertname: EnvoyDeploymentHasNoReplicas
  • deployment: scalar-envoy
```

#### Resolved

```console
[RESOLVED]
Alert: scalar-envoy: has no replicas. - critical
 Description: deployment scalar-envoy has 0 replicas
 Details:
  • alertname: EnvoyDeploymentHasNoReplicas
  • deployment: scalar-envoy
```

### Action Needed

* Check the number of replicas set `kubectl get deployments. scalar-envoy`

```console
$ kubectl get deployments. scalar-envoy
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
scalar-envoy   0/0     0            0           167m
```

```console
$ kubectl scale deployment  scalar-envoy --replicas 3
deployment.extensions/scalar-envoy scaled
```

## EnvoyDeploymentHasMissingReplicas

## EnvoyPodsPending

## EnvoyPodsError
