# Prepare bastion tool - Install Kubernetes CLI and Helm

This document explains how to install Kubernetes CLI, kubectl, and Helm on the bastion.

## Prepare Ansible configuration

First, you need to retrieve the public DNS for the bastion and user. Add it to the inventory.ini with Terraform output in network directory:

In `examples/azure/network/` directory

```console
terraform output bastion_ip
bastion-exemple-k8s-azure-fpjzfyk.eastus.cloudapp.azure.com
```

```console
terraform output user_name
centos
```

And add it as follow in the ansible inventory file (inventory.ini):

```console
[bastion]
bastion1 ansible_ssh_host=bastion-exemple-k8s-azure-fpjzfyk.eastus.cloudapp.azure.com ansible_user=centos
```

Secondly, you need to retrieve the kubernetes access file and save in the tmp folder as `kube_config` from the Terraform output command in Kubernetes modules.

In `examples/azure/kubernetes/` directory

```console
terraform output kube_config > kube_config
cp kube_config ../../../operation/tmp/kube_config
```

And open file `kube_config` in the `tmp` directory with your preferred editor. It should look like below.

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

## Install and configure bastion server

When the requirements are completed, you can run the following command to install the tools in the server that will proceed to the installation.

```console
ansible-playbook -i ../inventory.ini playbook-install-tools.yml

[OMIT]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************
bastion                    : ok=14   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Check installation

Go on the bastion and execute the following command to ensure you can interact with the Kubernetes cluster.

```console
[centos@bastion-1 ~]$ kubectl get node
NAME                                   STATUS     ROLES   AGE    VERSION
aks-default-34802672-vmss000000        Ready      agent   5h5m   v1.15.10
aks-scalardlpool-34802672-vmss000000   Ready      agent   5h     v1.15.10
aks-scalardlpool-34802672-vmss000001   Ready      agent   5h2m   v1.15.10
```
