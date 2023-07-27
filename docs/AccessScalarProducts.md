# Make ScalarDB or ScalarDL deployed in a Kubernetes cluster environment available from applications

This document explains how to make ScalarDB or ScalarDL deployed in a Kubernetes cluster environment available from applications. To make ScalarDB or ScalarDL available from applications, you can use Scalar Envoy via a Kubernetes service resource named `<HELM_RELEASE_NAME>-envoy`. You can use `<HELM_RELEASE_NAME>-envoy` in several ways, such as:

* Directly from inside the same Kubernetes cluster as ScalarDB or ScalarDL.
* Via a load balancer from outside the Kubernetes cluster.
* From a bastion server by using the `kubectl port-forward` command (for testing purposes only).

The resource name `<HELM_RELEASE_NAME>-envoy` is decided based on the helm release name. You can see the helm release name by running the `helm list` command.

```console
$ helm list -n ns-scalar
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS                                                       CHART                    APP VERSION
scalardb                ns-scalar       1               2023-02-09 19:31:40.527130674 +0900 JST deployed                                                     scalardb-2.5.0           3.8.0
scalardl-auditor        ns-scalar       1               2023-02-09 19:32:03.008986045 +0900 JST deployed                                                     scalardl-audit-2.5.1     3.7.1
scalardl-ledger         ns-scalar       1               2023-02-09 19:31:53.459548418 +0900 JST deployed                                                     scalardl-4.5.1           3.7.1
```

You can also see the envoy service name `<HELM_RELEASE_NAME>-envoy` by running the `kubectl get service` command.

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

## Run application (client) requests to ScalarDB or ScalarDL via service resources directly from inside the same Kubernetes cluster

If you deploy your application (client) in the same Kubernetes cluster as ScalarDB or ScalarDL (for example, if you deploy your application [client] on another node group or pool in the same Kubernetes cluster), the application can access ScalarDB or ScalarDL by using Kubernetes service resources. The format of the service resource name (FQDN) is `<HELM_RELEASE_NAME>-envoy.<NAMESPACE>.svc.cluster.local`.

The following are examples of ScalarDB and ScalarDL deployments on the `ns-scalar` namespace:

* **ScalarDB Server**
    ```console
    scalardb-envoy.ns-scalar.svc.cluster.local
    ```
* **ScalarDL Ledger**
    ```console
    scalardl-ledger-envoy.ns-scalar.svc.cluster.local
    ```
* **ScalarDL Auditor**
    ```console
    scalardl-auditor-envoy.ns-scalar.svc.cluster.local
    ```

When using the Kubernetes service resource, you must set the above FQDN in the properties file for the application (client) as follows:

* **Client properties file for ScalarDB Server**
    ```properties
    scalar.db.contact_points=<HELM_RELEASE_NAME>-envoy.<NAMESPACE>.svc.cluster.local
    scalar.db.contact_port=60051
    scalar.db.storage=grpc
    scalar.db.transaction_manager=grpc
    ```
* **Client properties file for ScalarDL Ledger**
    ```properties
    scalar.dl.client.server.host=<HELM_RELEASE_NAME>-envoy.<NAMESPACE>.svc.cluster.local
    scalar.dl.ledger.server.port=50051
    scalar.dl.ledger.server.privileged_port=50052
    ```
* **Client properties file for ScalarDL Ledger with ScalarDL Auditor mode enabled**
    ```properties
    # Ledger
    scalar.dl.client.server.host=<HELM_RELEASE_NAME>-envoy.<NAMESPACE>.svc.cluster.local
    scalar.dl.ledger.server.port=50051
    scalar.dl.ledger.server.privileged_port=50052
    
    # Auditor
    scalar.dl.client.auditor.enabled=true
    scalar.dl.client.auditor.host=<HELM_RELEASE_NAME>-envoy.<NAMESPACE>.svc.cluster.local
    scalar.dl.auditor.server.port=40051
    scalar.dl.auditor.server.privileged_port=40052
    ```

## Run application (client) requests to ScalarDB or ScalarDL via load balancers from outside the Kubernetes cluster

If you deploy your application (client) in an environment outside the Kubernetes cluster for ScalarDB or ScalarDL (for example, if you deploy your application [client] on another Kubernetes cluster, container platform, or server), the application can access ScalarDB or ScalarDL by using a load balancer that each cloud service provides.

You can create a load balancer by setting `envoy.service.type` to `LoadBalancer` in your custom values file. After configuring the custom values file, you can use Scalar Envoy through a Kubernetes service resource by using the load balancer. You can also set the load balancer configurations by using annotations.

For more details on how to configure your custom values file, see [Service configurations](https://github.com/scalar-labs/helm-charts/blob/main/docs/configure-custom-values-envoy.md#service-configurations).

When using a load balancer, you must set the FQDN or IP address of the load balancer in the properties file for the application (client) as follows.

* **Client properties file for ScalarDB Server**
    ```properties
    scalar.db.contact_points=<LOAD_BALANCER_FQDN_OR_IP_ADDRESS>
    scalar.db.contact_port=60051
    scalar.db.storage=grpc
    scalar.db.transaction_manager=grpc
    ```
* **Client properties file for ScalarDL Ledger**
    ```properties
    scalar.dl.client.server.host=<LOAD_BALANCER_FQDN_OR_IP_ADDRESS>
    scalar.dl.ledger.server.port=50051
    scalar.dl.ledger.server.privileged_port=50052
    ```
* **Client properties file for ScalarDL Ledger with ScalarDL Auditor mode enabled**
    ```properties
    # Ledger
    scalar.dl.client.server.host=<LOAD_BALANCER_FQDN_OR_IP_ADDRESS>
    scalar.dl.ledger.server.port=50051
    scalar.dl.ledger.server.privileged_port=50052
    
    # Auditor
    scalar.dl.client.auditor.enabled=true
    scalar.dl.client.auditor.host=<LOAD_BALANCER_FQDN_OR_IP_ADDRESS>
    scalar.dl.auditor.server.port=40051
    scalar.dl.auditor.server.privileged_port=40052
    ```

The concrete implementation of the load balancer and access method depend on the Kubernetes cluster. If you are using a managed Kubernetes cluster, see the following official documentation based on your cloud service provider:

* **Amazon Elastic Kubernetes Service (EKS)**
  * [Network load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)
* **Azure Kubernetes Service (AKS)**
  * [Use a public standard load balancer in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard)
  * [Use an internal load balancer with Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/internal-lb)

## Run client requests to ScalarDB or ScalarDL from a bastion server (for testing purposes only; not recommended in a production environment)

You can run client requests to ScalarDB or ScalarDL from a bastion server by running the `kubectl port-forward` command. If you create a ScalarDL Auditor mode environment, however, you must run two `kubectl port-forward` commands with different kubeconfig files from one bastion server to access two Kubernetes clusters.

1. **(ScalarDL Auditor mode only)** In the bastion server for ScalarDL Ledger, configure an existing kubeconfig file or add a new kubeconfig file to access the Kubernetes cluster for ScalarDL Auditor. For details on how to configure the kubeconfig file of each managed Kubernetes cluster, see [Configure kubeconfig](./CreateBastionServer.md#configure-kubeconfig).
2. Configure port forwarding to each service from the bastion server.
   * **ScalarDB Server**
     ```console
     kubectl port-forward -n <NAMESPACE> svc/<RELEASE_NAME>-envoy 60051:60051
     ```
   * **ScalarDL Ledger**
     ```console
     kubectl --context <CONTEXT_IN_KUBERNETES_FOR_SCALARDL_LEDGER> port-forward -n <NAMESPACE> svc/<RELEASE_NAME>-envoy 50051:50051
     kubectl --context <CONTEXT_IN_KUBERNETES_FOR_SCALARDL_LEDGER> port-forward -n <NAMESPACE> svc/<RELEASE_NAME>-envoy 50052:50052
     ```
   * **ScalarDL Auditor**
     ```console
     kubectl --context <CONTEXT_IN_KUBERNETES_FOR_SCALARDL_AUDITOR> port-forward -n <NAMESPACE> svc/<RELEASE_NAME>-envoy 40051:40051
     kubectl --context <CONTEXT_IN_KUBERNETES_FOR_SCALARDL_AUDITOR> port-forward -n <NAMESPACE> svc/<RELEASE_NAME>-envoy 40052:40052
     ```
3. Configure the properties file to access ScalarDB or ScalarDL via `localhost`.
   * **Client properties file for ScalarDB Server**
     ```properties
     scalar.db.contact_points=localhost
     scalar.db.contact_port=60051
     scalar.db.storage=grpc
     scalar.db.transaction_manager=grpc
     ```
   * **Client properties file for ScalarDL Ledger**
     ```properties
     scalar.dl.client.server.host=localhost
     scalar.dl.ledger.server.port=50051
     scalar.dl.ledger.server.privileged_port=50052
     ```
   * **Client properties file for ScalarDL Ledger with ScalarDL Auditor mode enabled**
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

