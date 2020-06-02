# Operation folder

to install the scalar-k8s solution

## structure

* roles directory: hold ansible roles
* tmp directory: for Temporary files from ansible
* [experimental directory](experimental/README.md): for automatic, use it at your own risk
* in this directory, you will find playbook-*.yml

## Ansible playbook-install-tools.yml 

The goal is to install any dependency on the admin server, e.g: kubectl helm, etc...

### Prepare configuration

First, you need to retrieve the public DNS for the bastion and user. Add it to the inventory.ini with Terraform output in network directory:

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

Secondly, you need to retrieve the kube_config and save in the tmp folder as `kube_config` with the Terraform output command in Kubernetes modules.

```console
terraform output kube_config
output has been removed as it is too long and contains sensitive credentials
```

And create a file called `kube_config` in the `tmp` directory with your preferred editor.

```yml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1C....
```

### Install and configure bastion server

When the requirements are completed, you can run the following command to install the tools in the server that will proceed to the installation.

```console
ansible-playbook -i ../inventory.ini playbook-install-tools.yml
```

result

```console
PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************
bastion1                   : ok=0   changed=16    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```

