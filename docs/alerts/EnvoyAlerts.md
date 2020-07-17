# Envoy Alerts

## EnvoyDeploymentHasNoReplicas

This is the most critical alert and indicates that an Envoy cluster is not able to process requests. This alert should be handled with the highest priority.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: scalar-envoy: has no replicas. - critical
 Description: deployment scalar-envoy has 0 replicas
 Details:
  • alertname: EnvoyDeploymentHasNoReplicas
  • deployment: scalar-envoy
```

#### Resolved

```
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

if zero replica, increase the number with:

```console
$ kubectl scale deployment  scalar-envoy --replicas 3
deployment.extensions/scalar-envoy scaled
```

## EnvoyDeploymentHasMissingReplicas

This alert lets you know if a kubernetes cluster cannot start envoy pods, which means that the cluster does not have enough resource or lost of one or many kubernetes nodes to run the deployment.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: scalar-envoy: has insuficient replicas. - warning
 Description: deployment scalar-envoy has 1 replica(s) unavailable.
 Details:
  • alertname: EnvoyDeploymentHasMissingReplicas
  • deployment: scalar-envoy
```

#### Resolved

```
[RESOLVED:1]
Alert: scalar-envoy: has insuficient replicas. - warning
 Description: deployment scalar-envoy has 1 replica(s) unavailable.
 Details:
  • alertname: EnvoyDeploymentHasMissingReplicas
  • deployment: scalar-envoy
```

### Action Needed

* Check the log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kube/<date>/*.log`
* Check kubernetes deployment with `kubectl describe deployments`
* Check nodes statuses with `kubectl get node -o wide`
* Check a cloud provider to see if there is any known issue. For example, you can check statues [here](https://status.azure.com/en-us/status) in Azure.

## EnvoyPodsPending

This alert lets you know if a kubernetes cluster cannot start envoy pods, which means that the cluster does not have the enough resource.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: Pod scalar-envoy-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod scalar-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minute.
 Details:
  • alertname: EnvoyPodsPending
  • deployment: scalar-envoy
```

#### Resolved

```
[RESOLVED:1]
Alert: Pod scalar-envoy-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod scalar-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minute.
 Details:
  • alertname: EnvoyPodsPending
  • deployment: scalar-envoy
```

### Action Needed

* Check log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kube/<date>/*.log`
* Check a kubernetes deployment with `kubectl describe pod scalar-envoy-xxxx-yyyy`
* Check kubernetes logs on the monitor server `/log/kube/<date>/*.log`

## EnvoyPodsError

This alert lets you know if a kubernetes cluster cannot start envoy pods for one of the following reasons.

* CrashLoopBackOff: application problem.
* CreateContainerConfigError: manifests or helm template have error in configmap or secrets.
* CreateContainerError: kubernetes problem.
* ErrImagePull: docker image not found.
* ImagePullBackOff: tells us that Kubernetes was not able to find the image.
* InvalidImageName: tag image contain only number not strings.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: Pod scalar-envoy-xxxx-yyyy in namespace default has an error status - warning
 Description: Pod scalar-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minutes.
 Details:
  • alertname: EnvoyPodsError
  • deployment: scalar-envoy
```

#### Resolved

```
[RESOLVED:1]
Alert: Pod scalar-envoy-xxxx-yyyy in namespace default has an error status - warning
 Description: Pod scalar-envoy-xxxx-yyyy in namespace default has been in pending status for more than 1 minutes.
 Details:
  • alertname: EnvoyPodsError
  • deployment: scalar-envoy
```

### Action Needed

* Check a kubernetes deployment with `kubectl describe pod scalar-envoy-xxxx-yyyy`
* Check the log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kube/<date>/*.log`
