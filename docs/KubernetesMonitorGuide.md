# Kubernetes Monitor Guide

This document explains how to deploy Prometheus operator on Kubernetes with Ansible. After following the doc, you will be able to use Grafana, Alertmanager, and Prometheus inside Kubernetes.

## Prerequisite

### Prepare SSH key

When you deploy a Scalar environment in terraform network, you need to provide a public/private key-pair.
This key-pair will be used to tunnel a connection to the monitoring system.
It is assumed that the private key is loaded into an ssh-agent.

```console
# Please update `/path/to/local-repository` before running the command.
$ export SCALAR_K8S_HOME=/path/to/local-repository
$ cd ${SCALAR_K8S_HOME}/example/azure/network
$ ssh-add example_key # private ssh key
```

### Prepare Ansible inventory

Please refer to [prepare ansible inventory](./PrepareBastionTool.md#prepare-ansible-inventory)

### Generate SSH Config

The following command will generate a `ssh.cfg` with `LocalForward` to access the Kubernetes API from your local machine.

```console
$ cd ${SCALAR_K8S_HOME}/example/azure/kubernetes
$ terraform output k8s_ssh_config
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
$ cd ${SCALAR_K8S_HOME}/example/azure/kubernetes
$ terraform output k8s_ssh_config > ssh.cfg
```

## Deploy Prometheus

Now let's deploy to Prometheus component inside Kubernetes with Ansible playbook `playbook-deploy-prometheus.yaml`

```console
$ cd ${SCALAR_K8S_HOME}/operation
$ ansible-playbook -i inventory.ini playbook-deploy-prometheus.yml

PLAY [Deploy Prometheus in Kubernetes] ************************************************************************************************************************************************************************

TASK [prometheus : Create folder on remote server] ************************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com]

[OMIT]

TASK [prometheus : Deploy prometheus with helm] ***************************************************************************************************************************************************************
changed: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com]

PLAY RECAP ****************************************************************************************************************************************************************************************************
bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## How to setup your `kubeconfig` to access Prometheus

You need to export the `kube_config` from terraform and after find `server` line and replace with `https://localhost:7000` . finally copy to ~/.kube/config

```console
$ cd ${SCALAR_K8S_HOME}/example/azure/kubernetes
$ terraform output kube_config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1...
    # server: https://scalar-k8s-c1eae570.fdc2c43xxxx.xxxxxx.xxxxx.xxxxxxxx.privatelink.japaneast.azmk8s.io:443
    server: https://localhost:7000
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

## How to access

Now let's access to Prometheus component on your local machine. Open the ssh port-forward to the bastion, and let it open.

```console
$ ssh -F ssh.cfg bastion
Warning: Permanently added 'bastion-example-k8s-azure-b8ci1si.eastus.cloudapp.azure.com,52.188.154.226' (ECDSA) to the list of known hosts.
[centos@bastion-1 ~]$
```

Let's have a look at Kubernetes service in the `monitoring` namespace to find the Kubernetes service name for Grafana, Prometheus and Alertmanager.

```console
$ kubectl get svc -n monitoring
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

### For Grafana on port 8080

```console
$ kubectl port-forward -n monitoring svc/prometheus-grafana 8080:80
Forwarding from 127.0.0.1:8080 -> 3000
Forwarding from [::1]:8080 -> 3000
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
```

### For Alert-manager on port 9093

```console
$ kubectl port-forward -n monitoring svc/prometheus-prometheus-oper-alertmanager 9093:9093
Forwarding from 127.0.0.1:9093 -> 9093
Forwarding from [::1]:9093 -> 9093
Handling connection for 9093
```

### For Prometheus on port 9090

```console
$ kubectl port-forward -n monitoring svc/prometheus-prometheus-oper-prometheus 9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090
```

## Add Monitoring target  with Service Monitor CRD

ServiceMonitor specifies how groups of Kubernetes services should be monitored. The Operator automatically generates Prometheus scrape configuration based on the current state of the objects in the API server.

### Envoy monitoring

```console
$ cd ${SCALAR_K8S_HOME}/operation/manifests/
$ kubectl create -f prometheus/envoy-service-monitor.yaml
servicemonitor.monitoring.coreos.com/scalar-envoy-metrics created
```

Now, we can view the metrics in Grafana/Prometheus web interface
