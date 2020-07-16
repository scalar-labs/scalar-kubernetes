# Ledger Alerts

## LedgerDeploymentHasNoReplicas

This is the most critical alert and indicates that the Ledger cluster is not able to process requests. This alert should be handled with the highest priority.

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

```
$ kubectl get deployments. scalar-ledger
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
scalar-ledger   0/0     0            0           167m
```

if zero replica, increase the number with:

```
$ kubectl scale deployment  scalar-ledger --replicas 3
deployment.extensions/scalar-ledger scaled
```

## LedgerDeploymentHasMissingReplicas

This alert let you know if the kubernetes cluster cannot start the ledger pod, this mean that the cluster does not have the enough resource or lost of one or many kubernetes nodes to run the deployment.

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

* Check log server to pinpoint root cause of failure with the kubernetes logs on the monitor server `/log/kube/<date>/*.log`
* Check the kubernetes deployment with `kubectl describe deployments`
* Check the nodes status with `kubectl get node -o wide`
* Check the cloud provider to see if there are any known issues in the deployed location https://status.azure.com/en-us/status

## LedgerPodsPending

This alert let you know if the kubernetes cluster cannot start the ledger pod, this mean that the cluster does not have the enough resource.

### Example Alert

#### Firing

```
[FIRING:1]
Alert: Pod scalar-ledger-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod scalar-ledger-xxxx-yyyy in namespace default has been in pending status for more than 5 minutes.
 Details:
  • alertname: LedgerPodsPending
  • deployment: scalar-ledger
```

#### Resolved

```
[RESOLVED:1]
Alert: Pod scalar-ledger-xxxx-yyyy in namespace default in pending status - warning
 Description: Pod scalar-ledger-xxxx-yyyy in namespace default has been in pending status for more than 5 minutes.
 Details:
  • alertname: LedgerPodsPending
  • deployment: scalar-ledger
```

### Action Needed

* Check log server to pinpoint root cause of failure with the kubernetes logs on the monitor server `/log/kube/<date>/*.log`
* Check the kubernetes deployment with `kubectl describe pod scalar-ledger-xxxx-yyyy`
* Check the kubernetes logs on the monitor server `/log/kube/<date>/*.log`

## LedgerPodsError

This alert let you know if the kubernetes cluster cannot start the ledger pod for many errors:

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
