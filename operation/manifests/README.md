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
service/scalar-envoy-metrics created
```

You can check if the pods and the services are properly deployed as follows.

```console
$ kubectl get po,svc,endpoints -o wide
NAME                                 READY   STATUS      RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/scalar-envoy-56c9cc4598-dwkvl    1/1     Running     0          2m14s   10.42.41.4     aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-envoy-56c9cc4598-dz6mr    1/1     Running     0          7m24s   10.42.41.37    aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-envoy-56c9cc4598-z6szw    1/1     Running     0          4m39s   10.42.40.245   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-6f895669bb-c5567   1/1     Running     0          25m     10.42.41.8     aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-6f895669bb-hzp4p   1/1     Running     0          25m     10.42.41.33    aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-6f895669bb-wqn27   1/1     Running     0          25m     10.42.40.215   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalardl-schema-bt7zx            0/1     Completed   0          25m     10.42.40.221   aks-scalardlpool-34802672-vmss000000   <none>           <none>

NAME                             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                           AGE     SELECTOR
service/kubernetes               ClusterIP      10.42.48.1     <none>          443/TCP                           89m     <none>
service/scalar-envoy             LoadBalancer   10.42.49.207   52.142.18.158   50051:32102/TCP,50052:32723/TCP   24m     app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=v1.0.0
service/scalar-envoy-metrics     ClusterIP      10.42.49.217   <none>          9001/TCP                          4m26s   app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=v1.0.0
service/scalar-ledger-headless   ClusterIP      None           <none>          <none>                            24m     app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=v2.0.7

NAME                               ENDPOINTS                                                           AGE
endpoints/kubernetes               10.42.40.4:443                                                      89m
endpoints/scalar-envoy             10.42.40.245:50052,10.42.41.37:50052,10.42.41.4:50052 + 3 more...   24m
endpoints/scalar-envoy-metrics     10.42.40.245:9001,10.42.41.37:9001,10.42.41.4:9001                  4m26s
endpoints/scalar-ledger-headless   10.42.40.215,10.42.41.33,10.42.41.8                                 24m
```

You can have access with the following public IP on port 50051 and 50052 (e.g: 52.224.20.56)

```console
$ kubectl get svc scalar-envoy
NAME           TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                           AGE
scalar-envoy   LoadBalancer   10.42.49.207   52.142.18.158   50051:32102/TCP,50052:32723/TCP   25m
```
