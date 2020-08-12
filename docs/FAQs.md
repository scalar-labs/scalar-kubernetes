# Frequently Asked Questions (FAQs)

## How to restart a scalar app pods ?

Get the list of application that can be rollout

```console
$ kubectl get deployments.apps
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
prod-scalardl-envoy    3/3     3            3           5h11m
prod-scalardl-ledger   3/3     3            3           5h11m
```

for example with `prod-scalardl-envoy`

```console
$ kubectl patch deployment prod-scalardl-envoy -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
deployment.apps/prod-scalardl-envoy patched
```

Check with `kubectl get deployments.apps`

```console
$ kubectl get deployments.apps
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
prod-scalardl-envoy    3/3     1            2           5h12m
prod-scalardl-ledger   3/3     3            3           5h12m
```

or with `rollout` sub command

```console
kubectl rollout status deployment prod-scalardl-envoy
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 2 of 3 updated replicas are available...
Waiting for deployment "prod-scalardl-envoy" rollout to finish: 2 of 3 updated replicas are available...
deployment "prod-scalardl-envoy" successfully rolled out
```

Notes that you will received a slack notification if activated

```
[FIRING:1] EnvoyClusterDegraded - warning
Alert: Envoy cluster is running in a degraded mode - warning
 Description: Envoy cluster is running in a degraded mode, some of the Envoy pods are not healthy.
 Details:
  • alertname: EnvoyClusterDegraded
  • app: Envoy
```

```
[RESOLVED] EnvoyClusterDegraded - warning
Alert: Envoy cluster is running in a degraded mode - warning
 Description: Envoy cluster is running in a degraded mode, some of the Envoy pods are not healthy.
 Details:
  • alertname: EnvoyClusterDegraded
  • app: Envoy
```

## Anything that are not recommended ?

- kubectl 