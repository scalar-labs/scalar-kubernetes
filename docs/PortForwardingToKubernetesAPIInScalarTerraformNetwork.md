# How to do port-forwarding to Kubnernetes API in scalar-terraform network

This document explains how to create an SSH port-forwarded connection to the Kubernetes API in the scalar-terraform network.

The Kubernetes cluster created with scalar-terraform doesn't expose the API server to the outside of the network. You will need an SSH connection to the bastion host that does port-forwarding to the Kubernetes API to operate from your local machine.

After following the doc, you will get an ssh.cfg file to establish an SSH connection to the bastion host and a kubeconfig file for accessing the Kubernetes API on the connection.

## Requirement

* Have completed [How to create Azure AKS with scalar-terraform](./AKSScalarTerraformDeploymentGuide.md)

## Create kubeconfig file

You can get the kubeconfig file from `terraform output` of the `kubernetes` module.

```console
cd ${SCALAR_K8S_HOME}/modules/azure/kubernetes/
terraform output kube_config > ~/.kube/config
```

Please replace the `server` in the output with `https://localhost:7000` as follows. `7000` is the default local port number which is forwarded to the Kubernetes API.

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1...
    server: https://localhost:7000 # <- Replace this line
  name: scalar-kubernetes
contexts:
...
```

## Create ssh.cfg file

The following command will generate an `ssh.cfg` to connect to the bastion. It contains `LocalForward 7000` to the Kubernetes API so that you can access the API from your local machine with the kube_config file created in the above section.

```console
cd ${SCALAR_K8S_HOME}/modules/azure/kubernetes
terraform output k8s_ssh_config > ${SCALAR_K8S_CONFIG_DIR}/ssh.cfg
```

The ssh.cfg file should look as follows.

```ssh
...
Host bastion
  HostName bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com
  User centos
  LocalForward 8000 monitor.internal.scalar-labs.com:80
  LocalForward 7000 scalar-k8s-72b7f3f4.15539fa5-307a-46e3-aec3-d0e625c5cf8e.privatelink.eastus.azmk8s.io:443
...
```

## Start port-forwarding

Now you can start port-forwarding to the Kubernetes API by opening an SSH connection to the bastion.
Please keep a terminal open that runs the SSH with the following command when you access the API from your local machine.

```console
cd ${SCALAR_K8S_CONFIG_DIR}
ssh -F ssh.cfg bastion
```

## How to access Kubernetes from your local machine

Let's access Kubernetes from your local machine.

```console
$ kubectl get po,svc,endpoints,nodes -o wide
NAME                                         READY   STATUS      RESTARTS   AGE    IP             NODE                                   NOMINATED NODE   READINESS GATES
pod/prod-scalardl-envoy-84db4dbf46-rphpx    1/1     Running     0          115s   10.42.41.56    aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/prod-scalardl-envoy-84db4dbf46-wx94v    1/1     Running     0          115s   10.42.40.210   aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/prod-scalardl-envoy-84db4dbf46-zmkwl    1/1     Running     0          115s   10.42.40.160   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/prod-scalardl-ledger-596c77dc5b-89t4w   1/1     Running     0          115s   10.42.40.116   aks-scalardlpool-34802672-vmss000000   <none>           <none>
pod/prod-scalardl-ledger-596c77dc5b-nvm2w   1/1     Running     0          115s   10.42.41.49    aks-scalardlpool-34802672-vmss000001   <none>           <none>
pod/prod-scalardl-ledger-596c77dc5b-pm4m9   1/1     Running     0          115s   10.42.41.122   aks-scalardlpool-34802672-vmss000002   <none>           <none>
pod/prod-scalardl-ledger-schema-d8t97       0/1     Completed   0          115s   10.42.40.82    aks-default-34802672-vmss000000        <none>           <none>

NAME                                     TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                           AGE    SELECTOR
service/kubernetes                       ClusterIP      10.42.48.1     <none>        443/TCP                           36m    <none>
service/prod-scalardl-envoy             LoadBalancer   10.42.50.239   10.42.44.4    50051:30702/TCP,50052:31533/TCP   115s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=prod,app.kubernetes.io/name=scalardl
service/prod-scalardl-envoy-metrics     ClusterIP      10.42.50.117   <none>        9001/TCP                          115s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=prod,app.kubernetes.io/name=scalardl
service/prod-scalardl-ledger-headless   ClusterIP      None           <none>        <none>                            115s   app.kubernetes.io/app=ledger,app.kubernetes.io/instance=prod,app.kubernetes.io/name=scalardl

NAME                                       ENDPOINTS                                                             AGE
endpoints/kubernetes                       10.42.40.4:443                                                        36m
endpoints/prod-scalardl-envoy             10.42.40.160:50052,10.42.40.210:50052,10.42.41.56:50052 + 3 more...   115s
endpoints/prod-scalardl-envoy-metrics     10.42.40.160:9001,10.42.40.210:9001,10.42.41.56:9001                  115s
endpoints/prod-scalardl-ledger-headless   10.42.40.116,10.42.41.122,10.42.41.49                                 115s

NAME                                        STATUS   ROLES   AGE   VERSION    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
node/aks-default-34802672-vmss000000        Ready    agent   31m   v1.16.13   10.42.40.5     <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
node/aks-scalardlpool-34802672-vmss000000   Ready    agent   27m   v1.16.13   10.42.40.106   <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
node/aks-scalardlpool-34802672-vmss000001   Ready    agent   27m   v1.16.13   10.42.40.207   <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
node/aks-scalardlpool-34802672-vmss000002   Ready    agent   27m   v1.16.13   10.42.41.52    <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
```

The private endpoint is 10.42.44.4 on port 50051 and 50052.
Please check out [Scalar DL Getting Started](https://scalardl.readthedocs.io/en/latest/getting-started/) to understand how to interact with the environment.

## How to SSH to Kubernetes nodes

To access the Kubernetes nodes, look at the `INTERNAL-IP` from `kubectl get nodes -o wide`

```console
$ cd ${SCALAR_K8S_CONFIG_DIR}
$ ssh -F ssh.cfg 10.42.40.5
Warning: Permanently added 'bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com,52.188.154.226' (ECDSA) to the list of known hosts.
Warning: Permanently added '10.42.40.5' (ECDSA) to the list of known hosts.
azureuser@aks-default-34802672-vmss000000:~$
```
