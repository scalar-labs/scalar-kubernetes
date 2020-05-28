# A Guide on How to Deploy Scalar DL Manually with kubectl

## Requirements

* kubectl version 1.5.10, instructions can be found [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.
Note that Kubernetes cluster needs to be set up properly in advance. This can be easily done with [the terraform module]().

## Preparation

### Create a secret for DockerHub

setup the docker registry secret to let kubernetes access to scalar-ledger image

```console
kubectl create secret docker-registry reg-docker-secrets \
  --docker-server=https://index.docker.io/v2/ \
  --docker-username={{ DOCKERHUB_USER }} \
  --docker-password={{ DOCKERHUB_ACCESS_TOKEN }}
```

### Create ConfigMaps

for envoy

```console
kubectl create cm envoy --from-file=configuration/envoy.yaml
```

for scalardl-schema

```console
kubectl create cm scalardl-schema --from-file=configuration/create_schema.cql
```

### Deploy the Scalar schema to Cassandra cluster

```console
kubectl create -f schema/scalardl-schema.yaml
job.batch/scalardl-schema created
```

you must wait until the job is completed as below.

```console
kubectl get po -w
NAME                    READY   STATUS      RESTARTS   AGE
scalardl-schema-6fp95   0/1     Completed   0          34s
```

## Deploy Scalar DL

It is now ready to deploy Scalar DL to the k8s cluster. To deploy Scalar DL, you need to deploy `scalar-ledger` containers and `envoy` containers in this order.

### Deploy Scalar Ledger

First, deploy `scalar-ledger` containers as follows.

```console
kubectl create -f ledger/
deployment.extensions/scalar-ledger created
service/scalar-ledger-headless created
```

Next, deploy `envoy proxy` container as follows.

```console
kubectl create -f envoy/
deployment.extensions/envoy created
service/envoy created
```

You can check if the pods and the services are properly deployed as follows.

```console
kubectl get po,svc,endpoints -o wide
NAME                                 READY   STATUS      RESTARTS   AGE   IP             NODE                                 NOMINATED NODE   READINESS GATES
pod/envoy-5f9c8cb97-c8cfx            1/1     Running     0          57m   10.42.40.176   aks-scalarapps-34802672-vmss000000   <none>           <none>
pod/envoy-5f9c8cb97-fwqzn            1/1     Running     0          57m   10.42.40.212   aks-scalarapps-34802672-vmss000001   <none>           <none>
pod/envoy-5f9c8cb97-xrxnc            1/1     Running     0          57m   10.42.40.180   aks-scalarapps-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-545dc596f8-v6jqz   1/1     Running     0          61m   10.42.41.37    aks-scalarapps-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-545dc596f8-z94qz   1/1     Running     0          61m   10.42.41.13    aks-scalarapps-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-545dc596f8-zg8kl   1/1     Running     0          61m   10.42.40.146   aks-scalarapps-34802672-vmss000000   <none>           <none>
pod/scalardl-schema-6fp95            0/1     Completed   0          63m   10.42.40.27    aks-default-34802672-vmss000000      <none>           <none>

NAME                             TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                           AGE    SELECTOR
service/envoy                    LoadBalancer   10.42.51.58   20.185.12.160   50051:32170/TCP,50052:31373/TCP   57m    app.kubernetes.io/name=envoy,app.kubernetes.io/version=v1.12.2
service/kubernetes               ClusterIP      10.42.48.1    <none>          443/TCP                           6h7m   <none>
service/scalar-ledger-headless   ClusterIP      None          <none>          <none>                            61m    app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=v2.0.5

NAME                               ENDPOINTS                                                              AGE
endpoints/envoy                    10.42.40.176:50052,10.42.40.180:50052,10.42.40.212:50052 + 3 more...   57m
endpoints/kubernetes               10.42.40.4:443                                                         6h7m
endpoints/scalar-ledger-headless   10.42.40.146,10.42.41.13,10.42.41.37                                   61m
```

You can have access with the following public IP on port 50051 and 50052

```console
kubectl get svc envoy
NAME    TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                           AGE
envoy   LoadBalancer   10.42.51.58   20.185.12.160   50051:32170/TCP,50052:31373/TCP   63m
```
