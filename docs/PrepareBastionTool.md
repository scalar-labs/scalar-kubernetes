# How to install Kubernetes CLI and Helm on the bastion

This document explains how to install Kubernetes CLI (kubectl) and Helm on the bastion. After following the doc, you will be able to do operations to the Kubernetes cluster on the bastion node.

## Prepare Ansible inventory

First, you create an Ansible inventory file that contains the hostname and the username of the bastion as follows.

```console
# Please update `/path/to/local-repository` before running the command.
$ export SCALAR_K8S_HOME=/path/to/local-repository

# Please update `/path/to/local-repository-config-dir` before running the command.
$ export SCALAR_K8S_CONFIG_DIR=/path/to/local-repository-config-dir

$ cd ${SCALAR_K8S_HOME}/examples/azure/network
$ terraform output inventory_ini > ${SCALAR_K8S_CONFIG_DIR}/inventory.ini
```

The inventory file should look like below.

```console
terraform output inventory_ini
[bastion]
bastion-example-k8s-azure-p5rzic.eastus.cloudapp.azure.com

[bastion:vars]
ansible_user=centos
ansible_python_interpreter=/usr/bin/python3

[all:vars]
internal_domain=internal.scalar-labs.com
```

## Prepare kubeconfig file

Secondly, you create a kubeconfig file that contains information required to access the kubernetes cluster as follows.

```console
$ cd ${SCALAR_K8S_HOME}/examples/azure/kubernetes/
$ terraform output kube_config > ${SCALAR_K8S_CONFIG_DIR}/kube_config
```

The kubeconfig file should look like below.

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

## Install tools in the bastion

Now let's install the tools in the bastion as follows.

```console
$ cd ${SCALAR_K8S_HOME}
$ export ANSIBLE_CONFIG=${SCALAR_K8S_HOME}/operation/ansible.cfg
$ ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini operation/playbook-install-tools.yml

PLAY [Install necessary kubernetes binary on bastion] ****************************************************************************************************************************************************************************************************************

[OMIT]

TASK [helm : Add stable charts repository from helm] *****************************************************************************************************************************************************************************************************************
changed: [bastion-example-k8s-azure-p5rzic.eastus.cloudapp.azure.com]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************
bastion-example-k8s-azure-p5rzic.eastus.cloudapp.azure.com : ok=15   changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

## Check installation

You can login to the bastion and check if the installation worked well as follows.

```console
$ ssh centos@bastion-example-k8s-azure-p5rzic.eastus.cloudapp.azure.com
[centos@bastion-1 ~]$ kubectl get node
NAME                                        STATUS   ROLES   AGE   VERSION    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-default-34802672-vmss000000        Ready    agent   60m   v1.16.10   10.42.40.5     <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000000   Ready    agent   56m   v1.16.10   10.42.40.106   <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000001   Ready    agent   56m   v1.16.10   10.42.40.207   <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
aks-scalardlpool-34802672-vmss000002   Ready    agent   56m   v1.16.10   10.42.41.52    <none>        Ubuntu 16.04.6 LTS   4.15.0-1089-azure   docker://3.0.10+azure
```
