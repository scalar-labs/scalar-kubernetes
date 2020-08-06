# Envoy Alerts

## EnvoyClusterDown

This is the most critical alert and indicates that an Envoy cluster is not able to process requests. This alert should be handled with the highest priority.

### Example Alert

#### Firing

```
[FIRING:1] EnvoyClusterDown - critical
Alert: Envoy cluster is down - critical
 Description: Envoy cluster is down, no resquest can be process
 Details:
  • alertname: EnvoyClusterDown
  • deployment: prod-scalardl-envoy
```

#### Resolved

```
[RESOLVED] EnvoyClusterDown - critical
Alert: Envoy cluster is down - critical
 Description: Envoy cluster is down, no resquest can be process
 Details:
  • alertname: EnvoyClusterDown
  • deployment: prod-scalardl-envoy
```

### Action Needed

* Check the number of replicas set `kubectl get deployments. prod-scalardl-envoy`
* Check the number of replicas set `kubectl describe deployments. prod-scalardl-envoy`
* Check nodes statuses with `kubectl get node -o wide`
* Check the log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kubernetes/<year>/<month>-<day>/kube.log`
* Check a cloud provider to see if there is any known issue. For example, you can check statues [here](https://status.azure.com/en-us/status) in Azure.

## EnvoyClusterDegraded

This alert lets you know if a kubernetes cluster cannot start envoy pods, which means that the cluster does not have enough resource or lost of one or many kubernetes nodes to run the deployment.

### Example Alert

#### Firing

```
[FIRING:1] EnvoyClusterDegraded - warning
Alert: Envoy cluster is running in a degraded mode - warning
 Description: Envoy cluster is running in a degraded mode, some of the Envoy pods are not healthy
 Details:
  • alertname: EnvoyClusterDegraded
  • deployment: prod-scalardl-envoy
```

#### Resolved

```
[RESOLVED] EnvoyClusterDegraded - warning
Alert: Envoy cluster is running in a degraded mode - warning
 Description: Envoy cluster is running in a degraded mode, some of the Envoy pods are not healthy
 Details:
  • alertname: EnvoyClusterDegraded
  • deployment: prod-scalardl-envoy
```

### Action Needed

* Check the log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kubernetes/<year>/<month>-<day>/kube.log` or `kubectl logs prod-scalardl-envoy-xxxx-yyyy`
* Check kubernetes deployment with `kubectl describe deployments prod-scalardl-envoy`
* Check replica set with `kubectl get replicasets.apps`
* Check nodes statuses with `kubectl get node -o wide`
* Check a cloud provider to see if there is any known issue. For example, you can check statues [here](https://status.azure.com/en-us/status) in Azure.

## EnvoyPodsPending

This alert lets you know if a kubernetes cluster cannot start envoy pods, which means that the cluster does not have the enough resource.

### Example Alert

#### Firing

```
[FIRING:1] EnvoyPodsPending - warning
Alert: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minute.
 Details:
  • alertname: EnvoyPodsPending
  • deployment: prod-scalardl-envoy
```

#### Resolved

```
[RESOLVED:1] EnvoyPodsPending - warning
Alert: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minute.
 Details:
  • alertname: EnvoyPodsPending
  • deployment: prod-scalardl-envoy
```

### Action Needed

* Check log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kube/<date>/*.log`
* Check a kubernetes deployment with `kubectl describe pod prod-scalardl-envoy-xxxx-yyyy`

## EnvoyPodsError

This alert lets you know if a kubernetes cluster cannot start envoy pods for one of the following reasons:

* CrashLoopBackOff
* CreateContainerConfigError
* CreateContainerError
* ErrImagePull
* ImagePullBackOff
* InvalidImageName

### Example Alert

#### Firing

```
[FIRING:1] EnvoyPodsError - warning
Alert: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default has an error status - warning
 Description: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minutes.
 Details:
  • alertname: EnvoyPodsError
  • deployment: prod-scalardl-envoy
```

#### Resolved

```
[RESOLVED:1] EnvoyPodsError - warning
Alert: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default has an error status - warning
 Description: Pod prod-scalardl-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minutes.
 Details:
  • alertname: EnvoyPodsError
  • deployment: prod-scalardl-envoy
```

### Action Needed

* Check a kubernetes deployment with `kubectl describe pod prod-scalardl-envoy-xxxx-yyyy`
* Check the log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kubernetes/<year>/<month>-<day>/kube.log`
