# Access Scalar products on a Kubernetes environment

This document explains how to access Scalar products on a Kubernetes environment.

## Access Scalar products via Load Balancer (Recommended in the production environment)

On a Kubernetes environment, you can access Scalar products via Scalar Envoy. And, in the production environment, it is recommended to use a Load Balancer provided by each cloud service to access Scalar Envoy on the managed Kubernetes cluster.

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
