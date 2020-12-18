# How to collect logs from Kubernetes applications

`scalar-kubernetes` uses Fluent Bit to collect logs from the applications of Kubernetes cluster. This document explains how to deploy Fluent Bit on Kubernetes with Ansible. After following the doc, you will be able to see collected logs in the monitor server.

## Requirements

* Have completed [How to create Azure AKS with scalar-terraform](./AKSScalarTerraformDeploymentGuide.md)
  * Make sure the monitor server is up and running.
  * Make sure you generated the ssh.cfg file in `${SCALAR_K8S_HOME}/modules/azure/network`
* There is the `inventory.ini` file in `${SCALAR_K8S_CONFIG_DIR}`. Please refer to [Prepare Ansible inventory](./PrepareBastionTool.md#prepare-ansible-inventory).

### Set up Fluent Bit Metrics for Prometheus

Fluent Bit comes with a built-in HTTP server that can be used to monitor the internal information and the metrics of each running plugin. More information about this feature can be found on the [official website](https://docs.fluentbit.io/manual/administration/monitoring)

Please make sure the monitor resources are created with [Kubernetes Monitor Guide](./K8sMonitorGuide.md).

By default, the Prometheus service monitor is created, you can deactivate it by setting `fluent_activate_metrics` to `no` in vars.

## Deploy Fluent Bit

Now let's deploy Fluent Bit to Kubernetes.

```console
$ cd ${SCALAR_K8S_HOME}
$ ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini playbooks/playbook-deploy-fluentbit.yml

PLAY [Deploy Fluentbit in Kubernetes] *************************************************************************************************************************************************************************

TASK [Fluentbit : Create folder on remote server] *************************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com] => (item=/home/centos/manifests)
ok: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com] => (item=/home/centos/manifests/fluentbit)

...

TASK [Fluentbit : Deploy ServiceMonitor for Fluentbit] *******************************************************************************************************************************************************
ok: [bastion-example-k8s-azure-by2-ot4.eastus.cloudapp.azure.com]

PLAY RECAP ****************************************************************************************************************************************************************************************************
bastion                    : ok=7    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## View log in Monitor server

Connect on the monitor server.

```console
cd ${SCALAR_K8S_HOME}/modules/azure/network
ssh -F ssh.cfg monitor.internal.scalar-labs.com
```

The Kubernetes log are located under `/log/kubernetes/` directory.

```console
$ tree
.
└── 2020
    └── 06-15
        └── kube.log
```
