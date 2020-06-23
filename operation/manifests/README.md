# A Guide on How to Deploy Scalar DL Manually with kubectl

## Requirements

* kubectl version 1.5.10, instructions can be found [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.
Note that Kubernetes cluster needs to be set up properly in advance. This can be easily done with the [terraform module](../../docs/README.md)

## Preparation

### Create a secret for DockerHub

Create a docker registry secret to let kubernetes access to scalar-ledger image

```console
kubectl create secret docker-registry reg-docker-secrets \
  --docker-server=https://index.docker.io/v2/ \
  --docker-username={{ DOCKERHUB_USER }} \
  --docker-password={{ DOCKERHUB_ACCESS_TOKEN }}
```

### Create ConfigMaps

We need to deploy the configuration of both application.

For scalardl schema:

```console
kubectl create cm scalardl-schema --from-file=configuration/create_schema.cql
```

### Deploy the Scalar schema to Cassandra cluster

```console
kubectl create -f schema/scalardl-schema.yaml
job.batch/scalardl-schema created
```

You must wait until the job is completed as below.

```console
kubectl get po -w
NAME                    READY   STATUS      RESTARTS   AGE
scalardl-schema-6fp95   0/1     Completed   0          34s
```

## Deploy Scalar DL

It is now ready to deploy Scalar DL to the k8s cluster. To deploy Scalar DL, you need to deploy `scalar-ledger` containers and `envoy` containers in this order.

### Deploy Scalar Ledger

First, deploy `scalar-ledger` containers as follows. Note we are using version 2.0.5 who include the gRPC health check binary.

```console
kubectl create -f ledger/
deployment.extensions/scalar-ledger created
service/scalar-ledger-headless created
```

Next, deploy `envoy proxy` container as follows. Note that we are using v1.14.1

```console
kubectl create -f envoy/
deployment.extensions/scalar-envoy created
service/scalar-envoy created
```

You can check if the pods and the services are properly deployed as follows.

```console
[centos@bastion-1 manifests]$ kubectl get po,svc,endpoints -o wide
NAME                                 READY   STATUS      RESTARTS   AGE   IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/scalar-envoy-7754bd6568-54jjx    1/1     Running     0          30s   10.42.40.227   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-envoy-7754bd6568-k2ggh    1/1     Running     0          30s   10.42.40.218   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-envoy-7754bd6568-z72tb    1/1     Running     0          16m   10.42.40.154   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-866c4bd6bb-bnmrk   1/1     Running     0          84m   10.42.40.139   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-866c4bd6bb-rcwhw   1/1     Running     0          84m   10.42.41.2     aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-866c4bd6bb-t528x   1/1     Running     0          84m   10.42.40.126   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalardl-schema-j29f9            0/1     Completed   0          32m   10.42.40.36    aks-default-34802672-vmss000000        <none>           <none>

NAME                             TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)                           AGE    SELECTOR
service/scalar-envoy             LoadBalancer   10.42.51.13   52.224.20.56   50051:31707/TCP,50052:30733/TCP   80m    app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=v1.0.0
service/kubernetes               ClusterIP      10.42.48.1    <none>         443/TCP                           3h3m   <none>
service/scalar-ledger-headless   ClusterIP      None          <none>         <none>                            84m    app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=v2.0.5

NAME                               ENDPOINTS                               AGE
endpoints/scalar-envoy             10.42.40.154:50052,10.42.40.154:50051   80m
endpoints/kubernetes               10.42.40.4:443                          3h3m
endpoints/scalar-ledger-headless   10.42.40.126,10.42.40.139,10.42.41.2    84m
```

You can have access with the following public IP on port 50051 and 50052 (e.g: 52.224.20.56)

```console
kubectl get svc envoy
NAME           TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)                           AGE
scalar-envoy   LoadBalancer   10.42.51.58   52.224.20.56   50051:32170/TCP,50052:31373/TCP   63m
```
