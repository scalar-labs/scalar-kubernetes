# Kubernetes Monitor Guide

The Scalar Kubernetes deployment tools include a Prometheus operator.

## How to access

See the document [SSH Guide](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/SSHGuide.md) for more information

## Kubernetes helpers

the following command will generate a `ssh.cfg` with kubernetes `LocalForward` to access easily to the Kubernetes API

```console
terraform output k8s_ssh_config
Host *
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no

Host bastion
  HostName bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com
  User centos
  LocalForward 8000 monitor.internal.scalar-labs.com:80
  LocalForward 7000 scalar-k8s-72b7f3f4.15539fa5-307a-46e3-aec3-d0e625c5cf8e.privatelink.eastus.azmk8s.io:443

Host *.internal.scalar-labs.com
  ProxyCommand ssh -F ssh.cfg bastion -W %h:%p

Host 10.*
  User azureuser
  ProxyCommand ssh -F ssh.cfg bastion -W %h:%p
```

```console
terraform output k8s_ssh_config > ssh.cfg
```

## How to setup your kubeconfig to access Prometheus

```yml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1...
    server: https://scalar-k8s-c1eae570.fdc2c430-cd60-4952-b269-28d1c1583ca7.privatelink.eastus.azmk8s.io:443
  name: scalar-kubernetes
contexts:
- context:
    cluster: scalar-kubernetes
    user: clusterUser_exemple-k8s-azure-znmhbo_scalar-kubernetes
  name: scalar-kubernetes
current-context: scalar-kubernetes
kind: Config
preferences: {}
users:
- name: clusterUser_exemple-k8s-azure-znmhbo_scalar-kubernetes
  user:
    client-certificate-data: LS0tLS1C....
    client-key-data: LS0tLS...
    token: 48fdda...
```

you need to rewrite `server` line with `https://localhost:7000`

Copy the file to ~/.kube/config

### Port-forward

```console
ssh -F ssh.cfg bastion
Warning: Permanently added 'bastion-paul-k8s-azure-b8ci1si.eastus.cloudapp.azure.com,52.188.154.226' (ECDSA) to the list of known hosts.
Last login: Wed Jun 10 08:17:24 2020 from softbank060115074058.bbtec.net
[centos@bastion-1 ~]$
```

on your local machine

```console
➜  kubernetes git:(add-prometheus) ✗ kubectl get svc -n monitoring
NAME                                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                     ClusterIP   None           <none>        9093/TCP,9094/TCP,9094/UDP   3h44m
prometheus-grafana                        ClusterIP   10.42.50.121   <none>        80/TCP                       3h44m
prometheus-kube-state-metrics             ClusterIP   10.42.51.164   <none>        8080/TCP                     3h44m
prometheus-operated                       ClusterIP   None           <none>        9090/TCP                     3h44m
prometheus-prometheus-node-exporter       ClusterIP   10.42.48.249   <none>        9100/TCP                     3h44m
prometheus-prometheus-oper-alertmanager   ClusterIP   10.42.49.217   <none>        9093/TCP                     3h44m
prometheus-prometheus-oper-operator       ClusterIP   10.42.50.156   <none>        8080/TCP,443/TCP             3h44m
prometheus-prometheus-oper-prometheus     ClusterIP   10.42.48.154   <none>        9090/TCP                     3h44m
```

Port-forward for grafana on port 8080

```console
➜  kubernetes git:(add-prometheus) ✗ kubectl port-forward -n monitoring svc/prometheus-grafana 8080:80
Forwarding from 127.0.0.1:8080 -> 3000
Forwarding from [::1]:8080 -> 3000
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
```

Port-forward for alert-manager on port 9093

```console
➜  kubernetes git:(add-prometheus) ✗ kubectl port-forward -n monitoring svc/prometheus-prometheus-oper-alertmanager 9093:9093
Forwarding from 127.0.0.1:9093 -> 9093
Forwarding from [::1]:9093 -> 9093
Handling connection for 9093
```

Port-forward for prometheus on port 9090

```console
kubectl port-forward -n monitoring svc/prometheus-prometheus-oper-prometheus 9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090
```
