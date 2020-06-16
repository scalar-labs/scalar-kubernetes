# How to collect logs from Kubernetes applications

`scalar-k8s` uses Fluent Bit to collect logs from the applications of kubernetes cluster. This document explains how to deploy Fluent Bit on Kubernetes with Ansible. After following the doc, you will be able to see collected logs in the monitor server.

## Requirements

### Prepare Ansible inventory

Please refer to [prepare ansible inventory](./PrepareBastionTool.md#prepare-ansible-inventory)

### Monitor server

Please refer to [Monitor server](https://github.com/scalar-labs/scalar-terraform/blob/master/examples/azure/README.md#create-monitor-resources)

### Prometheus Operator

Please refer to [Kubernetes Monitor Guide](./KubernetesMonitorGuide.md)

#### Setup Prometheus Metrics

By default, the Prometheus service monitor is created, you can disable it by setting `fluent_activate_metrics` to `no` in vars.

## Deploy Prometheus

Now let's deploy to Fluentbit component inside Kubernetes.

```console
cd ${SCALAR_K8S_HOME}/operation
➜  operation git:(add-prometheus) ✗ ansible-playbook -i inventory.ini playbook-deploy-fluentbit.yaml

PLAY [Deploy Fluentbit in Kubernetes] *************************************************************************************************************************************************************************

TASK [Fluentbit : Create folder on remote server] *************************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com] => (item=/home/centos/manifests)
ok: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com] => (item=/home/centos/manifests/fluentbit)

[OMIT]

TASK [Fluentbit : Deploy ServiceMonitor for Fluentbit] *******************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com]

PLAY RECAP ****************************************************************************************************************************************************************************************************
bastion                    : ok=7    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## View log in Monitor server

Connect on the monitor server, please refer to [SSH Guide](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/SSHGuide.md)

```console
ssh -F ssh.cfg monitor.internal.scalar-labs.com
```

The Kubernetes log are located under `/log/kubernetes/` directory.

```console
[centos@monitor-1 kubernetes]$ tree
.
└── 2020
    └── 06-15
        └── kube.log
```
