# What you might want to check on a regular basis

Most of the components deployed by scalar-k8s are self-healing with the help of the managed k8s services and k8s self-healing capability. There are also configured alerts that occur when some unexpected behavior happens. Thus, there shouldn't be so many things to do day by day for running a service with scalar-k8s. However, it is recommended to check the status of a system on a regular basis to see if everything is working fine. Here is the list of things you might want to do on a regular basis.

## Kubernetes

### Check if Pods are all healthy statues

Please check the kubernetes namespaces:

* `default` for Scalar DL
* `logging` for Fluent bit
* `monitoring` for Prometheus

What to check:

* `STATUS` is all `Running`
* `RESTARTS` number is all 0
* Pods are evenly distributed on the different nodes

See below the examples

```console
$ kubectl get po -o wide -n default
NAME                                         READY   STATUS      RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
load-schema-schema-loading-cassandra-tgqdd   0/1     Completed   0          3h58m   10.42.40.26    aks-default-34802672-vmss000000        <none>           <none>
prod-scalardl-envoy-568f9cbff9-5ws5v         1/1     Running     0          3h57m   10.42.41.63    aks-scalardlpool-34802672-vmss000002   <none>           <none>
prod-scalardl-envoy-568f9cbff9-gsj4r         1/1     Running     0          3h57m   10.42.40.157   aks-scalardlpool-34802672-vmss000000   <none>           <none>
prod-scalardl-envoy-568f9cbff9-jsck2         1/1     Running     0          3h57m   10.42.40.215   aks-scalardlpool-34802672-vmss000001   <none>           <none>
prod-scalardl-ledger-55d96b74f8-6rcfs        1/1     Running     0          3h57m   10.42.41.92    aks-scalardlpool-34802672-vmss000002   <none>           <none>
prod-scalardl-ledger-55d96b74f8-mfgnx        1/1     Running     0          3h57m   10.42.40.119   aks-scalardlpool-34802672-vmss000000   <none>           <none>
prod-scalardl-ledger-55d96b74f8-q4xmr        1/1     Running     0          3h57m   10.42.40.226   aks-scalardlpool-34802672-vmss000001   <none>           <none>
```

```console
$ kubectl get pod -n logging -o wide
NAME               READY   STATUS    RESTARTS   AGE    IP             NODE                                   NOMINATED NODE   READINESS GATES
fluent-bit-glbpf   1/1     Running   0          4h8m   10.42.40.203   aks-scalardlpool-34802672-vmss000000   <none>           <none>
fluent-bit-hpc4t   1/1     Running   0          4h8m   10.42.40.230   aks-scalardlpool-34802672-vmss000001   <none>           <none>
fluent-bit-wbcjv   1/1     Running   0          4h8m   10.42.40.14    aks-default-34802672-vmss000000        <none>           <none>
fluent-bit-xnpxh   1/1     Running   0          4h8m   10.42.41.95    aks-scalardlpool-34802672-vmss000002   <none>           <none>
```

```console
$ kubectl get pod -n monitoring -o wide
NAME                                                     READY   STATUS    RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
alertmanager-prometheus-prometheus-oper-alertmanager-0   2/2     Running   0          4h16m   10.42.40.49    aks-default-34802672-vmss000000        <none>           <none>
prometheus-grafana-599cbc6bf6-lb8tz                      2/2     Running   0          4h16m   10.42.40.86    aks-default-34802672-vmss000000        <none>           <none>
prometheus-kube-state-metrics-7844d8fc49-9smq7           1/1     Running   0          4h16m   10.42.40.28    aks-default-34802672-vmss000000        <none>           <none>
prometheus-prometheus-node-exporter-2vzrf                1/1     Running   0          4h16m   10.42.41.52    aks-scalardlpool-34802672-vmss000002   <none>           <none>
prometheus-prometheus-node-exporter-4m5p5                1/1     Running   0          4h16m   10.42.40.207   aks-scalardlpool-34802672-vmss000001   <none>           <none>
prometheus-prometheus-node-exporter-cqbjg                1/1     Running   0          4h16m   10.42.40.106   aks-scalardlpool-34802672-vmss000000   <none>           <none>
prometheus-prometheus-node-exporter-rf7zm                1/1     Running   0          4h16m   10.42.40.5     aks-default-34802672-vmss000000        <none>           <none>
prometheus-prometheus-oper-operator-67ccf47d85-wqzm6     2/2     Running   0          4h16m   10.42.40.61    aks-default-34802672-vmss000000        <none>           <none>
prometheus-prometheus-prometheus-oper-prometheus-0       3/3     Running   1          4h15m   10.42.40.89    aks-default-34802672-vmss000000        <none>           <none>
```

### Check if Nodes are all healthy statuses

```console
$ kubectl get nodes -o wide
NAME                                   STATUS   ROLES   AGE     VERSION    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-default-34802672-vmss000000        Ready    agent   5h37m   v1.16.10   10.42.40.5     <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000000   Ready    agent   5h32m   v1.16.10   10.42.40.106   <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000001   Ready    agent   5h32m   v1.16.10   10.42.40.207   <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000002   Ready    agent   5h32m   v1.16.10   10.42.41.52    <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
```

What to check:

* `STATUS` is all `Ready`

### Check if there is any event on Kubernetes

```console
$ kubectl get event -o wide --all-namespaces
No resources found
```

## Kubernetes Prometheus

See the guide [How to access](./KubernetesMonitorGuide.md#how-to-access)

[The targets](http://localhost:9090/targets) are the endpoints that Prometheus check to collect the metrics for each component.

  * `monitoring/prod-scalardl-envoy-metrics` should be always green otherwise It indicates a problem on the envoy pods
  * `monitoring/fluent-bit-logging-metrics` should be always green otherwise It indicates a problem on the fluentbit pods`

[The rules](http://localhost:9090/rules) for EnvoyAlerts and LedgerAlerts are in `OK` states and thee is no error.

[Grafana](http://localhost:8080) look for any anomaly on the graph:

  * `Envoy Proxy` dashboard
  * `Scalar DLT Response` dashboard
  * Other dashboard:
    * `Kubernetes / Compute Resources / Cluster`
    * `Kubernetes / Compute Resources / Namespace (Workloads)`
    * `Kubernetes / Compute Resources / Pod`
    * `CoreDNS`

## Monitor Prometheus

See the guide [How to access](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/MonitorGuide.md#how-to-access)

[The targets](hhttp://localhost:8000/#prometheus) are the endpoints that Prometheus check to collect the metrics for each component.

  * `Cassandra` should be always green otherwise It indicates a problem on the envoy pods

[The rules](hhttp://localhost:8000/#prometheus) for Cassandra Alerts, Docker Container Alerts and Instance Alerts are in state `OK` and no error.

[Grafana](http://localhost:3000) look for any anomaly on the graph:

 * [Cassandra](http://localhost:3000/d/cassandra/cassandra?orgId=1) and select scalar keyspace
