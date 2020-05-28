# A Guide on How to Deploy Scalar DL Manually with kubectl

## Requirements

* kubectl version 1.5.10
* Helm version 2.16.3
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.
Note that Kubernetes cluster needs to be set up properly in advance. This can be easily done with [the terraform module]().

### kubectl

Kubectl tool install instructions can be found [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

#### Install kubectl

```console
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.7/bin/linux/amd64/kubectl
mv kubectl $PATH/kubectl
chmod +x $PATH/kubectl
```

#### Verify kubectl

```console
kubectl version
```

you should get:

```console
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.7", GitCommit:"6c143d35bb11d74970e7bc0b6c45b6bfdffc0bd4", GitTreeState:"clean", BuildDate:"2019-12-11T12:42:56Z", GoVersion:"go1.12.12", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.10", GitCommit:"059c666b8d0cce7219d2958e6ecc3198072de9bc", GitTreeState:"clean", BuildDate:"2020-04-03T15:17:29Z", GoVersion:"go1.12.12", Compiler:"gc", Platform:"linux/amd64"}
```

### Preparation

#### Create a secret for DockerHub

setup the docker registry on kubernetes

```console
kubectl create secret docker-registry reg-docker-secrets \
  --docker-server=https://index.docker.io/v2/ \
  --docker-username=<your-name> \
  --docker-password=<your-pword> \
```

you need to adapt with the username and password (can be a token as well)

#### Create ConfigMaps

for envoy

```console
kubectl create cm envoy --from-file=configuration/envoy.yaml
```

for scalardl-schema

```console
kubectl create cm scalardl-schema --from-file=configuration/create_schema.cql
```

#### Deploy the scalar schema

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

#### Deploy Scalar DL

It is now ready to deploy Scalar DL to the k8s cluster. To deploy Scalar DL, you need to deploy `scalar-ledger` containers and `envoy` containers in this order.

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
[centos@bastion-1 ~]$ kubectl get po,svc,endpoints -o wide
NAME                                 READY   STATUS    RESTARTS   AGE     IP             NODE                               NOMINATED NODE   READINESS GATES
pod/envoy-679ff5c767-24qgs           1/1     Running   0          4h57m   10.42.40.248   aks-scalardl-34802672-vmss000001   <none>           <none>
pod/envoy-679ff5c767-2th4k           1/1     Running   0          4h57m   10.42.40.122   aks-scalardl-34802672-vmss000000   <none>           <none>
pod/envoy-679ff5c767-zw9zx           1/1     Running   0          4h57m   10.42.40.125   aks-scalardl-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-5596d7646d-9rtlx   1/1     Running   0          5h14m   10.42.40.234   aks-scalardl-34802672-vmss000001   <none>           <none>
pod/scalar-ledger-5596d7646d-jw792   1/1     Running   0          5h14m   10.42.40.134   aks-scalardl-34802672-vmss000000   <none>           <none>
pod/scalar-ledger-5596d7646d-ln6m6   1/1     Running   0          5h14m   10.42.40.232   aks-scalardl-34802672-vmss000001   <none>           <none>

NAME                             TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                           AGE     SELECTOR
service/envoy                    LoadBalancer   10.42.51.34   52.186.98.155   50051:30093/TCP,50052:32101/TCP   4h57m   app.kubernetes.io/name=envoy,app.kubernetes.io/version=v1
service/kubernetes               ClusterIP      10.42.48.1    <none>          443/TCP                           6h32m   <none>
service/scalar-ledger-headless   ClusterIP      None          <none>          <none>                            30m     app.kubernetes.io/name=scalar-ledger,app.kubernetes.io/version=v1

NAME                               ENDPOINTS                                                              AGE
endpoints/envoy                    10.42.40.122:50052,10.42.40.125:50052,10.42.40.248:50052 + 3 more...   4h57m
endpoints/kubernetes               10.42.40.4:443                                                         6h32m
endpoints/scalar-ledger-headless   10.42.40.134,10.42.40.232,10.42.40.234                                 30m
```

now you can run kelpie or scalar-samples project to try out.
