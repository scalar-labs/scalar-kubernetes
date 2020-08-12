# Daily Check

This document explains how/what to check in a daily matter

## Kubernetes Prometheus

See the guide [How to access](./KubernetesMonitorGuide.md#how-to-access)

### Check the Prometheus Targets

the target are the endpoint which Prometheus check to collect the metrics for each components

URL: http://localhost:9090/targets

all the target should be green

Important:

- monitoring/prod-scalardl-envoy-metrics should be always green, otherwise It indicate a problem on the envoy pods
- monitoring/fluent-bit-logging-metrics hould be always green, otherwise It indicate a problem on the fluentbit pods

### Check the Prometheus Rules

Check if the rules for EnvoyAlerts and LedgerAlerts are in state `OK` and no error.

URL: http://localhost:9090/rules

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

## Monitor Prometheus

See the guide [How to access](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/MonitorGuide.md#how-to-access)

- cassandra

## Kubernetes

- kubectl get pod -o wide
- kubectl get pod -n kube-system -o wide
- kubectl get nodes -o wide
- kubectl get events
