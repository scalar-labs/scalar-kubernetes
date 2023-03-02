# Access Scalar products on a Kubernetes environment

This document explains how to access Scalar products on a Kubernetes environment. On a Kubernetes environment, you can access Scalar products via Scalar Envoy. To access this Scalar Envoy via service resource of Kubernetes named as `<helm release name>-envoy`. There are several ways to access this `<helm release name>-envoy` service resource as follows.

* Access `<helm release name>-envoy` directly from **inside** of the same Kubernetes cluster as Scalar products.
* Access `<helm release name>-envoy` via a Load Balancer from **outside** of the Kubernetes cluster.
* Access `<helm release name>-envoy` from a bastion server using the `kubectl port-forward` command (testing purpose only).

Also, the resource name `<helm release name>-envoy` is decided based on the helm release name. You can see the helm release name using the `helm list` command.

```console
$ helm list -n ns-scalar
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS                                                       CHART                    APP VERSION
scalardb                ns-scalar       1               2023-02-09 19:31:40.527130674 +0900 JST deployed                                                     scalardb-2.5.0           3.8.0
scalardl-auditor        ns-scalar       1               2023-02-09 19:32:03.008986045 +0900 JST deployed                                                     scalardl-audit-2.5.1     3.7.1
scalardl-ledger         ns-scalar       1               2023-02-09 19:31:53.459548418 +0900 JST deployed                                                     scalardl-4.5.1           3.7.1
```

You can also see the envoy service name `<helm release name>-envoy` directly using the `kubectl get service` command.

```console
$ kubectl get service -n ns-scalar
NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                           AGE
scalardb-envoy                   LoadBalancer   10.99.245.143    <pending>     60051:31110/TCP                   2m2s
scalardb-envoy-metrics           ClusterIP      10.104.56.87     <none>        9001/TCP                          2m2s
scalardb-headless                ClusterIP      None             <none>        60051/TCP                         2m2s
scalardb-metrics                 ClusterIP      10.111.213.194   <none>        8080/TCP                          2m2s
scalardl-auditor-envoy           LoadBalancer   10.111.141.43    <pending>     40051:31553/TCP,40052:31171/TCP   99s
scalardl-auditor-envoy-metrics   ClusterIP      10.104.245.188   <none>        9001/TCP                          99s
scalardl-auditor-headless        ClusterIP      None             <none>        40051/TCP,40053/TCP,40052/TCP     99s
scalardl-auditor-metrics         ClusterIP      10.105.119.158   <none>        8080/TCP                          99s
scalardl-ledger-envoy            LoadBalancer   10.96.239.167    <pending>     50051:32714/TCP,50052:30857/TCP   109s
scalardl-ledger-envoy-metrics    ClusterIP      10.97.204.18     <none>        9001/TCP                          109s
scalardl-ledger-headless         ClusterIP      None             <none>        50051/TCP,50053/TCP,50052/TCP     109s
scalardl-ledger-metrics          ClusterIP      10.104.216.189   <none>        8080/TCP                          109s
```

## Access Scalar products via service resources directly from inside of the Kubernetes cluster

If you deploy your application (client) on the same Kubernetes cluster as Scalar products (e.g., you deploy your application on another node group/pool on the same Kubernetes cluster), the application can access Scalar products using service resources of Kubernetes. The format of the service resource name (FQDN) is `<helm release name>-envoy.<namespace>.svc.cluster.local`.

* Example (if you deploy Scalar products on the `ns-scalar` namespace)
  * ScalarDB Server
    ```console
    scalardb-envoy.ns-scalar.svc.cluster.local
    ```
  * ScalarDL Ledger
    ```console
    scalardl-ledger-envoy.ns-scalar.svc.cluster.local
    ```
  * ScalarDL Auditor
    ```console
    scalardl-auditor-envoy.ns-scalar.svc.cluster.local
    ```

If you use the service resource of Kubernetes, you need to set the above FQDN in the properties file for the application (client) as follows.

* Client properties file for ScalarDB Server
  ```properties
  scalar.db.contact_points=<helm release name>-envoy.<namespace>.svc.cluster.local
  scalar.db.contact_port=60051
  scalar.db.storage=grpc
  scalar.db.transaction_manager=grpc
  ```
* Client properties file for ScalarDL Ledger
  ```properties
  scalar.dl.client.server.host=<helm release name>-envoy.<namespace>.svc.cluster.local
  scalar.dl.ledger.server.port=50051
  scalar.dl.ledger.server.privileged_port=50052
  ```
* Client properties file for ScalarDL Ledger and ScalarDL Auditor (Auditor mode)
  ```properties
  # Ledger
  scalar.dl.client.server.host=<helm release name>-envoy.<namespace>.svc.cluster.local
  scalar.dl.ledger.server.port=50051
  scalar.dl.ledger.server.privileged_port=50052
  
  # Auditor
  scalar.dl.client.auditor.enabled=true
  scalar.dl.client.auditor.host=<helm release name>-envoy.<namespace>.svc.cluster.local
  scalar.dl.auditor.server.port=40051
  scalar.dl.auditor.server.privileged_port=40052
  ```

## Access Scalar products via Load Balancers from outside of the Kubernetes cluster

If you deploy your application (client) on another environment than the Kubernetes cluster for Scalar products (e.g., you deploy your application on another  Kubernetes cluster, container platform, or server), the application can access Scalar products using a Load Balancer provided by each cloud service.

You can create the Load Balancer to set `envoy.service.type` to `LoadBalancer` in your custom values file. When you create it, you can access Scalar Envoy (A service resource of Kubernetes) via created Load Balancer. You can also configure the Load Balancer configurations using annotations. Please refer to the following document for more details on how to configure your custom values file.

* [Service configurations](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-envoy.md#service-configurations)

If you use the Load Balancer, you need to set the FQDN or IP address of the Load Balancer in the properties file for the application (client) as follows.

* Client properties file for ScalarDB Server
  ```properties
  scalar.db.contact_points=<FQDN or IP address of Load Balancer>
  scalar.db.contact_port=60051
  scalar.db.storage=grpc
  scalar.db.transaction_manager=grpc
  ```
* Client properties file for ScalarDL Ledger
  ```properties
  scalar.dl.client.server.host=<FQDN or IP address of Load Balancer>
  scalar.dl.ledger.server.port=50051
  scalar.dl.ledger.server.privileged_port=50052
  ```
* Client properties file for ScalarDL Ledger and ScalarDL Auditor (Auditor mode)
  ```properties
  # Ledger
  scalar.dl.client.server.host=<FQDN or IP address of Load Balancer>
  scalar.dl.ledger.server.port=50051
  scalar.dl.ledger.server.privileged_port=50052
  
  # Auditor
  scalar.dl.client.auditor.enabled=true
  scalar.dl.client.auditor.host=<FQDN or IP address of Load Balancer>
  scalar.dl.auditor.server.port=40051
  scalar.dl.auditor.server.privileged_port=40052
  ```

The concrete implementation of the Load Balancer and access method depend on the Kubernetes cluster. If you use a managed Kubernetes cluster, please refer to the following cloud provider's official documents for more details.

### EKS

* [Network load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)

### AKS

* [Use a public standard load balancer in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard)
* [Use an internal load balancer with Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/internal-lb)

## Access Scalar products from a bastion server (For testing purposes only / Not recommended in the production environment)

You can access Scalar products from a bastion server using the `kubectl port-forward` command. If you create a ScalarDL Auditor mode environment, you need to access two Kubernetes clusters from one bastion server to access ScalarDL this way.

1. (ScalarDL Auditor mode only) In the bastion server for ScalarDL Ledger, configure (add) the kubeconfig to access the Kubernetes cluster of ScalarDL Auditor.

   Please refer to the following document for more details on how to configure the kubeconfig of each managed Kubernetes cluster.

   * [Configure kubeconfig](./CreateBastionServer.md#configure-kubeconfig)

1. Port forwarding to each service from the bastion server.
   * ScalarDB Server
     ```console
     kubectl port-forward -n <namespace> svc/<release name>-envoy 60051:60051
     ```
   * ScalarDL Ledger
     ```console
     kubectl --context <context of k8s for Ledger> port-forward -n <namespace> svc/<release name>-envoy 50051:50051
     kubectl --context <context of k8s for Ledger> port-forward -n <namespace> svc/<release name>-envoy 50052:50052
     ```
   * ScalarDL Auditor
     ```console
     kubectl --context <context of k8s for Auditor> port-forward -n <namespace> svc/<release name>-envoy 40051:40051
     kubectl --context <context of k8s for Auditor> port-forward -n <namespace> svc/<release name>-envoy 40052:40052
     ```

1. Configure properties file to access each Scalar product via `localhost`. 
   * Client properties file for ScalarDB Server
     ```properties
     scalar.db.contact_points=localhost
     scalar.db.contact_port=60051
     scalar.db.storage=grpc
     scalar.db.transaction_manager=grpc
     ```
   * Client properties file for ScalarDL Ledger
     ```properties
     scalar.dl.client.server.host=localhost
     scalar.dl.ledger.server.port=50051
     scalar.dl.ledger.server.privileged_port=50052
     ```
   * Client properties file for ScalarDL Ledger and ScalarDL Auditor (Auditor mode)
     ```properties
     # Ledger
     scalar.dl.client.server.host=localhost
     scalar.dl.ledger.server.port=50051
     scalar.dl.ledger.server.privileged_port=50052
     
     # Auditor
     scalar.dl.client.auditor.enabled=true
     scalar.dl.client.auditor.host=localhost
     scalar.dl.auditor.server.port=40051
     scalar.dl.auditor.server.privileged_port=40052
     ```
