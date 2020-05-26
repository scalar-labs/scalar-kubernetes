# Operation folder

to install the scalar-k8s solution

## structure

* config directory: to store helm configuration values files e.g: envoy and ledger and other
* experimental directory: help to speed thing, use at your own risk
* roles directory: hold ansible roles
* tmp directory: for Temporary files from ansible

## install-tools.yml playbook

the goal is to install any dependency on the admin server e.g: kubectl helm, etc...

### requirements

first, you need to retrieve the public dns for the bastion and add it to the inventory.ini

example:

```console
[bastion]
bastion1 bastion-exemple-k8s-azure-xfqpq9g.eastus.cloudapp.azure.com
```

second, you need to retrieve the kube_config and save in the tmp folder as `kube_config`

```yml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1C....
```

### run

when the requirements are completed, you can run the following command to install the tools in the server

```console
ansible-playbook -i ../inventory.ini install-tools.yml
```