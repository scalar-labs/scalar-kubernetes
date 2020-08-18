# What you might want to check on a regular basis

This document explains how/what to check in a daily matter

## Kubernetes Prometheus

See the guide [How to access](./KubernetesMonitorGuide.md#how-to-access)

### Check the Prometheus Targets

the target are the endpoint which Prometheus check to collect the metrics for each components

Available [Here](http://localhost:9090/targets)

Important:

- monitoring/prod-scalardl-envoy-metrics should be always green, otherwise It indicate a problem on the envoy pods
- monitoring/fluent-bit-logging-metrics hould be always green, otherwise It indicate a problem on the fluentbit pods

### Check the Prometheus Rules

Check if the rules for EnvoyAlerts and LedgerAlerts are in state `OK` and no error.

Available [Here](http://localhost:9090/rules)

### Check the Grafana for Envoy Proxy

Go on grafana and check `Envoy Proxy` dashboard, look for any anomaly on the graph

### Check the Grafana for Scalar DLT Response

Go on grafana and check `Scalar DLT Response` dashboard, look for any anomaly on the graph

### Other Dashboard to check

Go on grafana and check the list below dashboard, look for any anomaly on the graph

* Kubernetes / Compute Resources / Cluster
* Kubernetes / Compute Resources / Namespace (Workloads)
* Kubernetes / Compute Resources / Pod
* CoreDNS

## Monitor server Prometheus

See the guide [How to access](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/MonitorGuide.md#how-to-access)

### Check the Prometheus Targets

the target are the endpoint which Prometheus check to collect the metrics for each components

Available [Here](http://localhost:8000/#prometheus) and go to Targets

Important
- cassandra

### Check the Prometheus Rules

Check if the rules for Cassandra Alerts, Docker Container Alerts and Instance Alerts are in state `OK` and no error.

Available [Here](http://localhost:8000/#prometheus) and go to Rules

### Check the Grafana for Cassandra

Go on grafana and check `Casssandra` dashboard, look for any anomaly on the graph

Available [Here](http://localhost:3000/d/cassandra/cassandra?orgId=1) and select scalar keyspace

## Kubernetes

### Check Scalar apps pods

```console
$ kubectl get po -o wide
NAME                                         READY   STATUS      RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
load-schema-schema-loading-cassandra-tgqdd   0/1     Completed   0          3h58m   10.42.40.26    aks-default-34802672-vmss000000        <none>           <none>
prod-scalardl-envoy-568f9cbff9-5ws5v         1/1     Running     0          3h57m   10.42.41.63    aks-scalardlpool-34802672-vmss000002   <none>           <none>
prod-scalardl-envoy-568f9cbff9-gsj4r         1/1     Running     0          3h57m   10.42.40.157   aks-scalardlpool-34802672-vmss000000   <none>           <none>
prod-scalardl-envoy-568f9cbff9-jsck2         1/1     Running     0          3h57m   10.42.40.215   aks-scalardlpool-34802672-vmss000001   <none>           <none>
prod-scalardl-ledger-55d96b74f8-6rcfs        1/1     Running     0          3h57m   10.42.41.92    aks-scalardlpool-34802672-vmss000002   <none>           <none>
prod-scalardl-ledger-55d96b74f8-mfgnx        1/1     Running     0          3h57m   10.42.40.119   aks-scalardlpool-34802672-vmss000000   <none>           <none>
prod-scalardl-ledger-55d96b74f8-q4xmr        1/1     Running     0          3h57m   10.42.40.226   aks-scalardlpool-34802672-vmss000001   <none>           <none>
```

What to check:

* Pods are correctly in states of `Running` status
* Pods didn't restarted, check RESTARTS column
* Pods are correctly distributed on the different nodes

### Check Kubernetes Pods

```console
$ kubectl get pod -n kube-system -o wide
NAME                                         READY   STATUS    RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
azure-cni-networkmonitor-7nqcr               1/1     Running   0          5h27m   10.42.41.52    aks-scalardlpool-34802672-vmss000002   <none>           <none>
azure-cni-networkmonitor-jzssl               1/1     Running   0          5h27m   10.42.40.207   aks-scalardlpool-34802672-vmss000001   <none>           <none>
azure-cni-networkmonitor-k97d9               1/1     Running   0          5h27m   10.42.40.106   aks-scalardlpool-34802672-vmss000000   <none>           <none>
azure-cni-networkmonitor-n5t85               1/1     Running   0          5h32m   10.42.40.5     aks-default-34802672-vmss000000        <none>           <none>
azure-ip-masq-agent-cw7cs                    1/1     Running   0          5h27m   10.42.40.106   aks-scalardlpool-34802672-vmss000000   <none>           <none>
azure-ip-masq-agent-hxhbb                    1/1     Running   0          5h32m   10.42.40.5     aks-default-34802672-vmss000000        <none>           <none>
azure-ip-masq-agent-p7n5b                    1/1     Running   0          5h27m   10.42.40.207   aks-scalardlpool-34802672-vmss000001   <none>           <none>
azure-ip-masq-agent-rttbw                    1/1     Running   0          5h27m   10.42.41.52    aks-scalardlpool-34802672-vmss000002   <none>           <none>
coredns-869cb84759-frtsh                     1/1     Running   0          5h36m   10.42.40.74    aks-default-34802672-vmss000000        <none>           <none>
coredns-869cb84759-w2z2t                     1/1     Running   0          5h31m   10.42.40.75    aks-default-34802672-vmss000000        <none>           <none>
coredns-autoscaler-5b867494f-z4x8t           1/1     Running   0          5h36m   10.42.40.59    aks-default-34802672-vmss000000        <none>           <none>
dashboard-metrics-scraper-566c858889-tq8cw   1/1     Running   0          5h36m   10.42.40.27    aks-default-34802672-vmss000000        <none>           <none>
kube-proxy-28675                             1/1     Running   0          5h32m   10.42.40.5     aks-default-34802672-vmss000000        <none>           <none>
kube-proxy-7lnm5                             1/1     Running   0          5h27m   10.42.40.207   aks-scalardlpool-34802672-vmss000001   <none>           <none>
kube-proxy-9l5d7                             1/1     Running   0          5h27m   10.42.41.52    aks-scalardlpool-34802672-vmss000002   <none>           <none>
kube-proxy-nrw2n                             1/1     Running   0          5h27m   10.42.40.106   aks-scalardlpool-34802672-vmss000000   <none>           <none>
kubernetes-dashboard-7f7d6bbd7f-c8qwr        1/1     Running   0          5h36m   10.42.40.16    aks-default-34802672-vmss000000        <none>           <none>
metrics-server-6cd7558856-hhs49              1/1     Running   0          5h36m   10.42.40.102   aks-default-34802672-vmss000000        <none>           <none>
tunnelfront-7599bc65f9-zv5mc                 2/2     Running   0          5h36m   10.42.40.98    aks-default-34802672-vmss000000        <none>           <none>
```

What to check:

* Pods are correctly in states of `Running` status
* Pods didn't restarted, check RESTARTS column
* Pods are correctly distributed on the different nodes

### Check Fluent bit Pods

```console
$ kubectl get pod -n logging -o wide
NAME               READY   STATUS    RESTARTS   AGE    IP             NODE                                   NOMINATED NODE   READINESS GATES
fluent-bit-glbpf   1/1     Running   0          4h8m   10.42.40.203   aks-scalardlpool-34802672-vmss000000   <none>           <none>
fluent-bit-hpc4t   1/1     Running   0          4h8m   10.42.40.230   aks-scalardlpool-34802672-vmss000001   <none>           <none>
fluent-bit-wbcjv   1/1     Running   0          4h8m   10.42.40.14    aks-default-34802672-vmss000000        <none>           <none>
fluent-bit-xnpxh   1/1     Running   0          4h8m   10.42.41.95    aks-scalardlpool-34802672-vmss000002   <none>           <none>
```

What to check:

* Pods are correctly in states of `Running` status
* Pods didn't restarted, check RESTARTS column
* Pods are correctly distributed on the different nodes

### Check the Prometheus Pods

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

What to check:

* Pods are correctly in states of `Running` status
* Pods didn't restarted, check RESTARTS column
* Pods are correctly distributed on the different nodes

### Check the Nodes status

```console
$ kubectl get nodes -o wide
NAME                                   STATUS   ROLES   AGE     VERSION    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-default-34802672-vmss000000        Ready    agent   5h37m   v1.16.10   10.42.40.5     <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000000   Ready    agent   5h32m   v1.16.10   10.42.40.106   <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000001   Ready    agent   5h32m   v1.16.10   10.42.40.207   <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000002   Ready    agent   5h32m   v1.16.10   10.42.41.52    <none>        Ubuntu 16.04.6 LTS   4.15.0-1091-azure   docker://3.0.10+azure
```

What to check:

* check if the status are `Ready`

### Check if there is any events on Kubernetes

```console
$ kubectl get event -o wide --all-namespaces
No resources found
```
