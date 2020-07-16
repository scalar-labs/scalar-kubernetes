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

You can check if the pods and the services are properly deployed as follows:

* Check the Pods are in the Status `Running` or `Completed` for jobs
* Check the Pods `envoy` and `ledger` are well distributed on the k8s node pool e.g: `aks-scalardlpool-*`
* Check the `scalar-envoy` Service has a public IP in `EXTERNAL-IP` (take about 30s to 1min to setup)

```console
$ kubectl get po,svc,endpoints -o wide
NAME                                 READY   STATUS      RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/scalar-envoy-7dc48c76bb-cbxlg    1/1     Running     0          4m6s    10.42.40.125   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalar-envoy-7dc48c76bb-gpmbh    1/1     Running     0          4m6s    10.42.41.76    aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/scalar-envoy-7dc48c76bb-qw2bj    1/1     Running     0          4m6s    10.42.40.215   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-6db6689f86-8kkbf   1/1     Running     0          8m55s   10.42.41.33    aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-6db6689f86-9j7ql   1/1     Running     0          8m55s   10.42.41.147   aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/scalar-ledger-6db6689f86-m9hg9   1/1     Running     0          8m55s   10.42.40.138   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/scalardl-schema-58rpq            0/1     Completed   0          9m26s   10.42.40.18    aks-default-34802672-vmss000000        <none>           <none>

NAME                             TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                           AGE     SELECTOR
service/kubernetes               ClusterIP      10.42.48.1    <none>        443/TCP                           6h55m   <none>
service/scalar-envoy             LoadBalancer   10.42.48.93   40.81.9.127   50051:31582/TCP,50052:32741/TCP   4m6s    app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=v1.0.0
service/scalar-envoy-metrics     ClusterIP      10.42.48.87   <none>        9001/TCP                          4m6s    app.kubernetes.io/name=scalar-envoy,app.kubernetes.io/version=v1.0.0
service/scalar-ledger-headless   ClusterIP      None          <none>        <none>                            8m55s   app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=v2.0.7

NAME                               ENDPOINTS                                                              AGE
endpoints/kubernetes               10.42.40.4:443                                                         6h55m
endpoints/scalar-envoy             10.42.40.125:50052,10.42.40.215:50052,10.42.41.76:50052 + 3 more...    4m6s
endpoints/scalar-envoy-metrics     10.42.40.125:9001,10.42.40.215:9001,10.42.41.76:9001                   4m6s
endpoints/scalar-ledger-headless   10.42.40.138,10.42.41.147,10.42.41.33                                  8m55s
```

You can have access with the following public IP on port 50051 and 50052 (e.g: 52.224.20.56)

```console
$ kubectl get svc scalar-envoy
NAME           TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                           AGE
scalar-envoy   LoadBalancer   10.42.49.207   52.142.18.158   50051:32102/TCP,50052:32723/TCP   25m
```
