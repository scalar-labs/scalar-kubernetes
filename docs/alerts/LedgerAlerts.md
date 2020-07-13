# Ledger Alerts

## LedgerDeploymentHasNoReplicas

This is the most critical alert and indicates that the Ledger cluster is not able to process requests. This alert should be handled with the highest priority.

### Example Alert

#### Firing

```console
[FIRING:1]
Alert: scalar-ledger: has no replicas. - critical
 Description: deployment scalar-ledger has 0 replicas
 Details:
  • alertname: LedgerDeploymentHasNoReplicas
  • deployment: scalar-ledger
```

#### Resolved

```console
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

```console
$ kubectl scale deployment  scalar-ledger --replicas 3
deployment.extensions/scalar-ledger scaled
```

## LedgerDeploymentHasMissingReplicas

### Example Alert



#### Firing

#### Resolved

### Action Needed

## LedgerPodsPending

### Example Alert

#### Firing

#### Resolved

### Action Needed

## LedgerPodsError

### Example Alert

#### Firing

#### Resolved

### Action Needed