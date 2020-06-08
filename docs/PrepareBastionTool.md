# How to install Kubernetes CLI and Helm on the bastion

This document explains how to install Kubernetes CLI (kubectl) and Helm on the bastion. After following the doc, you will be able to do operations to the Kubernetes cluster on the bastion node.

## Prepare Ansible inventory

First, you create an Ansible inventory file that contains the hostname and the username of the bastion as follows.

In `examples/azure/network/` directory, execute the following command

```console
cd ${SCALAR_K8S_HOME}/examples/azure/network
terraform output inventory_ini > ${SCALAR_K8S_HOME}/operation/inventory.ini
```

The inventory file should look like below.

```console
terraform output inventory_ini
[bastion]
bastion-paul-k8s-azure-p5rzic.eastus.cloudapp.azure.com

[bastion:vars]
ansible_user=centos
ansible_python_interpreter=/usr/bin/python3
```

Secondly, you create a kubeconfig file that contains information required to access the kubernetes cluster as follows.

In `examples/azure/kubernetes/` directory, execute the following command

```console
cd ${SCALAR_K8S_HOME}/examples/azure/kubernetes/
terraform output kube_config > ${SCALAR_K8S_HOME}/operation/tmp/kube_config
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

In `operation` directory, execute the following command

```console
cd ${SCALAR_K8S_HOME}
ansible-playbook -i inventory.ini playbook-install-tools.yml

PLAY [Install necessary kubernetes binary on bastion] ****************************************************************************************************************************************************************************************************************

[OMIT]

TASK [helm : Add stable charts repository from helm] *****************************************************************************************************************************************************************************************************************
changed: [bastion-paul-k8s-azure-p5rzic.eastus.cloudapp.azure.com]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************
bastion-paul-k8s-azure-p5rzic.eastus.cloudapp.azure.com : ok=15   changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

## Check installation

You can login to the bastion and check if the installation worked well as follows.

```console
[centos@bastion-1 ~]$ kubectl get node
NAME                                   STATUS     ROLES   AGE    VERSION
aks-default-34802672-vmss000000        Ready      agent   5h5m   v1.15.10
aks-scalardlpool-34802672-vmss000000   Ready      agent   5h     v1.15.10
aks-scalardlpool-34802672-vmss000001   Ready      agent   5h2m   v1.15.10
```
