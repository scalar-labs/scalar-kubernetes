# Monitoring Scalar products on a Kubernetes cluster

This document explains how to deploy Prometheus Operator on Kubernetes with Helm. After following this document, you can use Prometheus, Alertmanager, and Grafana for monitoring Scalar products on your Kubernetes environment.

If you use a managed Kubernetes cluster and you want to use the cloud service features for monitoring and logging, please refer to the following document.

* [Logging and monitoring on Amazon EKS](https://docs.aws.amazon.com/prescriptive-guidance/latest/implementing-logging-monitoring-cloudwatch/amazon-eks-logging-monitoring.html)
* [Monitoring Azure Kubernetes Service (AKS) with Azure Monitor](https://learn.microsoft.com/en-us/azure/aks/monitor-aks)

## Prerequisites

* Create a Kubernetes cluster.
    * [Create an EKS cluster for Scalar products](./CreateEKSClusterForScalarProducts.md)
    * [Create an AKS cluster for Scalar products](./CreateAKSClusterForScalarProducts.md)
* Create a Bastion server and set `kubeconfig`.
    * [Create a bastion server](./CreateBastionServer.md)

## Add the prometheus-community helm repository

This document uses Helm for the deployment of Prometheus Operator.

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
```console
helm repo update
```

## Prepare a custom values file

Please get the sample file [scalar-prometheus-custom-values.yaml](https://github.com/scalar-labs/scalar-kubernetes/blob/master/conf/scalar-prometheus-custom-values.yaml) for kube-prometheus-stack. For the monitoring of Scalar products, this sample file's configuration is recommended.

In this sample file, the Service resources are not exposed to access from outside of a Kubernetes cluster. If you want to access dashboards from outside of your Kubernetes cluster, you must set `*.service.type` to `LoadBalancer` or `*.ingress.enabled` to `true`.

Please refer to the following official document for more details on the configurations of kube-prometheus-stack.

* [kube-prometheus-stack - Configuration](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#configuration)

## Deploy Prometheus Operator

Scalar products assume the Prometheus Operator is deployed in the `monitoring` namespace by default. So, please create the namespace `monitoring` and deploy Prometheus Operator in the `monitoring` namespace.

1. Create a namespace `monitoring` on Kubernetes.
   ```console
   kubectl create namespace monitoring
   ```

1. Deploy the kube-prometheus-stack.
   ```console
   helm install scalar-monitoring prometheus-community/kube-prometheus-stack -n monitoring -f scalar-prometheus-custom-values.yaml
   ```

## Check if the Prometheus Operator is deployed

If the Prometheus Operator (includes Prometheus, Alertmanager, and Grafana) pods are deployed properly, you can see the `STATUS` is `Running` using the `kubectl get pod -n monitoring` command.

```
$ kubectl get pod -n monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-scalar-monitoring-kube-pro-alertmanager-0   2/2     Running   0          55s
prometheus-scalar-monitoring-kube-pro-prometheus-0       2/2     Running   0          55s
scalar-monitoring-grafana-cb4f9f86b-jmkpz                3/3     Running   0          62s
scalar-monitoring-kube-pro-operator-865bbb8454-9ppkc     1/1     Running   0          62s
```

## Deploy (or Upgrade) Scalar products using Helm Charts

1. To enable Prometheus monitoring for Scalar products, you must set `true` to the following configurations in the custom values file.

   * Configurations
       * `*.prometheusRule.enabled`
       * `*.grafanaDashboard.enabled`
       * `*.serviceMonitor.enabled`

   Please refer to the following documents for more details on the custom values file of each Scalar product.

   * [ScalarDB Server](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-scalardb.md#prometheusgrafana-configurations)
   * [ScalarDB GraphQL](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-scalardb-graphql.md#prometheusgrafana-configurations)
   * [ScalarDL Ledger](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-scalardl-ledger.md#prometheusgrafana-configurations)
   * [ScalarDL Auditor](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-scalardl-auditor.md#prometheusgrafana-configurations)

1. Deploy (or Upgrade) Scalar products using Helm Charts with the above custom values file.

   Please refer to the following documents for more details on how to deploy/upgrade Scalar products.

   * [ScalarDB Server](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalardb.md)
   * [ScalarDB GraphQL](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalardb-graphql.md)
   * [ScalarDL Ledger](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalardl-ledger.md)
   * [ScalarDL Auditor](https://github.com/scalar-labs/helm-charts/blob/main/docs/how-to-deploy-scalardl-auditor.md)

## How to access dashboards

When you set `*.service.type` to `LoadBalancer` or `*.ingress.enabled` to `true`, you can access dashboards via Service or Ingress of Kubernetes. The concrete implementation and access method depend on the Kubernetes cluster. If you use a managed Kubernetes cluster, please refer to the cloud provider's official document for more details.

* EKS
    * [Network load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)
    * [Application load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
* AKS
    * [Use a public standard load balancer in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard)
    * [Create an ingress controller in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/ingress-basic)

## Access the dashboard from your local machine (For testing purposes only / Not recommended in the production environment)

You can access each dashboard from your local machine using the `kubectl port-forward` command.

1. Port forwarding to each service from your local machine.
   * Prometheus
     ```console
     kubectl port-forward -n monitoring svc/scalar-monitoring-kube-pro-prometheus 9090:9090
     ```
   * Alertmanager
     ```console
     kubectl port-forward -n monitoring svc/scalar-monitoring-kube-pro-alertmanager 9093:9093
     ```
   * Grafana
     ```console
     kubectl port-forward -n monitoring svc/scalar-monitoring-grafana 3000:3000
     ```

1. Access each Dashboard.
   * Prometheus
     ```console
     http://localhost:9090/
     ```
   * Alertmanager
     ```console
     http://localhost:9093/
     ```
   * Grafana
     ```console
     http://localhost:3000/
     ```
       * Note:
           * You can see the user and password of Grafana as follows.
               * user
                 ```console
                 kubectl get secrets scalar-monitoring-grafana -n monitoring -o jsonpath='{.data.admin-user}' | base64 -d
                 ```
               * password
                 ```console
                 kubectl get secrets scalar-monitoring-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
                 ```
