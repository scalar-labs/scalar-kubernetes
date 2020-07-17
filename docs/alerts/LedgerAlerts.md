# Ledger Alerts

## LedgerDeploymentHasNoReplicas

This is the most critical alert and indicates that an Ledger cluster is not able to process requests. This alert should be handled with the highest priority.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: scalar-ledger: has no replicas. - critical
 Description: deployment scalar-ledger has 0 replicas
 Details:
  • alertname: LedgerDeploymentHasNoReplicas
  • deployment: scalar-ledger
```

#### Resolved

```
[RESOLVED]
Alert: scalar-ledger: has no replicas. - critical
 Description: deployment scalar-ledger has 0 replicas
 Details:
  • alertname: LedgerDeploymentHasNoReplicas
  • deployment: scalar-ledger
```

### Action Needed

* Check the number of replicas set `kubectl get deployments. scalar-ledger`

```console
$ kubectl get deployments. scalar-ledger
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
scalar-ledger   0/0     0            0           167m
```

if zero replica, increase the number with:

```console
$ kubectl scale deployment  scalar-ledger --replicas 3
deployment.extensions/scalar-ledger scaled
```

## LedgerDeploymentHasMissingReplicas

This alert lets you know if a kubernetes cluster cannot start ledger pods, which means that the cluster does not have enough resource or lost of one or many kubernetes nodes to run the deployment.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: scalar-ledger: has insuficient replicas. - warning
 Description: deployment scalar-ledger has 1 replica(s) unavailable.
 Details:
  • alertname: LedgerDeploymentHasMissingReplicas
  • deployment: scalar-ledger
```

#### Resolved

```
[RESOLVED:1]
Alert: scalar-ledger: has insuficient replicas. - warning
 Description: deployment scalar-ledger has 1 replica(s) unavailable.
 Details:
  • alertname: LedgerDeploymentHasMissingReplicas
  • deployment: scalar-ledger
```

### Action Needed

* Check the log server to pinpoint the root cause of a failure with kubernetes logs on the monitor server `/log/kube/<date>/*.log`
* Check kubernetes deployment with `kubectl describe deployments`
* Check nodes statuses with `kubectl get node -o wide`
* Check a cloud provider to see if there is any known issue. For example, you can check statues [here](https://status.azure.com/en-us/status) in Azure.

## LedgerPodsPending

This alert lets you know if a kubernetes cluster cannot start ledger pods, which means that the cluster does not have the enough resource.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: Pod scalar-ledger-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod scalar-ledger-xxxx-yyyy in namespace default has been in pending status for more than 1 minute.
 Details:
  • alertname: LedgerPodsPending
  • deployment: scalar-ledger
```

#### Resolved

```
[RESOLVED:1]
Alert: Pod scalar-ledger-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod scalar-ledger-xxxx-yyyy in namespace default has been in pending status for more than 1 minute.
 Details:
  • alertname: LedgerPodsPending
  • deployment: scalar-ledger
```

### Action Needed

* Check log server to pinpoint root cause of failure with the kubernetes logs on the monitor server `/log/kube/<date>/*.log`
* Check the kubernetes deployment with `kubectl describe pod scalar-ledger-xxxx-yyyy`
* Check the kubernetes logs on the monitor server `/log/kube/<date>/*.log`

## LedgerPodsError

This alert lets you know if a kubernetes cluster cannot start ledger pods for one of the following reasons.

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
Alert: Pod scalar-ledger-xxxx-yyyy in namespace default has an error status - warning
 Description: Pod scalar-ledger-xxxx-yyyy in namespace default has been in pending status for more than 1 minutes.
 Details:
  • alertname: LedgerPodsError
  • deployment: scalar-ledger
```

#### Resolved

```
[RESOLVED:1]
Alert: Pod scalar-ledger-xxxx-yyyy in namespace default has an error status - warning
 Description: Pod scalar-ledger-xxxx-yyyy in namespace default has been in pending status for more than 1 minutes.
 Details:
  • alertname: LedgerPodsError
  • deployment: scalar-ledger
```

### Action Needed

* Check the kubernetes deployment with `kubectl describe pod scalar-ledger-xxxx-yyyy`
* Check log server to pinpoint root cause of failure with the kubernetes logs on the monitor server `/log/kube/<date>/*.log`
