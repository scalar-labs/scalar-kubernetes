# Components to Regularly Check When Running in a Kubernetes Environment

Most of the components deployed by manual deployment guides are self-healing with the help of the managed Kubernetes services and Kubernetes self-healing capability. There are also configured alerts that occur when some unexpected behavior happens. Thus, there shouldn't be so many things to do day by day for the deployment of Scalar products on the managed Kubernetes cluster. However, it is recommended to check the status of a system on a regular basis to see if everything is working fine. Here is the list of things you might want to do on a regular basis.

## Kubernetes resources

### Check if Pods are all healthy statues

Please check the Kubernetes namespaces:

* `default` (or specified namespace when you deploy Scalar products) for the Scalar product deployment
* `monitoring` for the Prometheus Operator and Loki

What to check:

* `STATUS` is all `Running`
* Pods are evenly distributed on the different nodes

```console
$ kubectl get pod -o wide -n <namespace>
NAME                              READY   STATUS    RESTARTS   AGE     IP           NODE          NOMINATED NODE   READINESS GATES
scalardb-7876f595bd-2jb28         1/1     Running   0          2m35s   10.244.2.6   k8s-worker2   <none>           <none>
scalardb-7876f595bd-rfvk6         1/1     Running   0          2m35s   10.244.1.8   k8s-worker    <none>           <none>
scalardb-7876f595bd-xfkv4         1/1     Running   0          2m35s   10.244.3.8   k8s-worker3   <none>           <none>
scalardb-envoy-84c475f77b-cflkn   1/1     Running   0          2m35s   10.244.1.7   k8s-worker    <none>           <none>
scalardb-envoy-84c475f77b-tzmc9   1/1     Running   0          2m35s   10.244.3.7   k8s-worker3   <none>           <none>
scalardb-envoy-84c475f77b-vztqr   1/1     Running   0          2m35s   10.244.2.5   k8s-worker2   <none>           <none>
```

```console
$ kubectl get pod -n monitoring -o wide
NAME                                                     READY   STATUS    RESTARTS      AGE   IP           NODE                NOMINATED NODE   READINESS GATES
alertmanager-scalar-monitoring-kube-pro-alertmanager-0   2/2     Running   1 (11m ago)   12m   10.244.2.4   k8s-worker2         <none>           <none>
prometheus-scalar-monitoring-kube-pro-prometheus-0       2/2     Running   0             12m   10.244.1.5   k8s-worker          <none>           <none>
scalar-logging-loki-0                                    1/1     Running   0             13m   10.244.2.2   k8s-worker2         <none>           <none>
scalar-logging-loki-promtail-2c4k9                       0/1     Running   0             13m   10.244.0.5   k8s-control-plane   <none>           <none>
scalar-logging-loki-promtail-8r48b                       1/1     Running   0             13m   10.244.3.2   k8s-worker3         <none>           <none>
scalar-logging-loki-promtail-b26c6                       1/1     Running   0             13m   10.244.2.3   k8s-worker2         <none>           <none>
scalar-logging-loki-promtail-sks56                       1/1     Running   0             13m   10.244.1.2   k8s-worker          <none>           <none>
scalar-monitoring-grafana-77c4dbdd85-4mrn7               3/3     Running   0             12m   10.244.3.4   k8s-worker3         <none>           <none>
scalar-monitoring-kube-pro-operator-7575dd8bbd-bxhrc     1/1     Running   0             12m   10.244.1.3   k8s-worker          <none>           <none>
```

### Check if Nodes are all healthy statuses

What to check:

* `STATUS` is all `Ready`

```console
$ kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
k8s-control-plane   Ready    control-plane   16m   v1.25.3
k8s-worker          Ready    <none>          15m   v1.25.3
k8s-worker2         Ready    <none>          15m   v1.25.3
k8s-worker3         Ready    <none>          15m   v1.25.3
```

## Prometheus dashboard (Alerts of Scalar products)

Access to the Prometheus dashboard according to the document [Monitoring Scalar products on the Kubernetes cluster](./K8sMonitorGuide.md). In the **Alerts** tab, you can see the alert status.

What to check:

* All alerts are **green (Inactive)**

If some issue is occurring, it shows you **red (Firing)** status.

## Grafana dashboard (metrics of Scalar products)

Access to the Grafana dashboard according to the document [Monitoring Scalar products on the Kubernetes cluster](./K8sMonitorGuide.md). In the **Dashboards** tab, you can see the dashboard of Scalar products. In these dashboards, you can see some metrics of Scalar products.

Those dashboards cannot address issues directly, but you can see changes from normal (e.g., increasing transaction errors) to get hints for investigating issues.
