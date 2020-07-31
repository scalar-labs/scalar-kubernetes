# How to collect logs from Kubernetes applications

`scalar-k8s` uses Fluent Bit to collect logs from the applications of Kubernetes cluster. This document explains how to deploy Fluent Bit on Kubernetes with Ansible. After following the doc, you will be able to see collected logs in the monitor server.

## Requirements

### Prepare Ansible inventory

Setting up Ansible inventory is required to install Fluent Bit with Ansible. Please refer to [prepare ansible inventory](./PrepareBastionTool.md#prepare-ansible-inventory) for how to set up an ansible inventory.

### Set up Monitor server

Monitor server must be up and running before start collecting logs.
please refer to [Monitor server](https://github.com/scalar-labs/scalar-terraform/blob/master/examples/azure/README.md#create-monitor-resources) for how to set up Monitor server.

### Set up Fluent Bit Metrics for Prometheus

Fluent Bit comes with a built-in HTTP server that can be used to monitor the internal information and the metrics of each running plugin. More information about this feature can be found on the [official website](https://docs.fluentbit.io/manual/administration/monitoring)

Please also make sure monitor resources are created with [Kubernetes Monitor Guide](./KubernetesMonitorGuide.md).

By default, the Prometheus service monitor is created, you can deactivate it by setting `fluent_activate_metrics` to `no` in vars.

## Deploy Fluent Bit

Now let's deploy Fluent Bit to Kubernetes.

```console
$ cd ${SCALAR_K8S_HOME}
$ ansible-playbook -i outputs/example/inventory.ini operation/playbook-deploy-fluentbit.yml

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
$ cd ${SCALAR_K8S_HOME}
$ ssh -F outputs/example/ssh.cfg monitor.internal.scalar-labs.com
```

The Kubernetes log are located under `/log/kubernetes/` directory.

```console
$ tree
.
└── 2020
    └── 06-15
        └── kube.log
```
