# Experimental features

Collection of ansible-playbook to deploy your environment for Azure cloud

## Setup

this script is to spin up TF modules (Network, Kubernetes, Cassandra) in azure

To run the following ansible-playbook, you need to prepare TF_variables_file for each module with your criteria before starting this playbook.

```console
ansible-playbook -i ../inventory.ini playbook-setup.yaml
```

or if you want to do one per one

```console
ansible-playbook -i ../inventory.ini playbook-setup.yaml --step
```

or per modules e.g.: network, Kubernetes, Cassandra

```console
ansible-playbook -i ../inventory.ini playbook-setup.yaml --tags network,kubernetes
```

## Teardown

this script is to un-deploy TF modules (Network, Kubernetes, Cassandra) in azure

```console
ansible-playbook -i ../inventory.ini playbook-teardown.yaml
```

## automatic configuration provisioning

the playbook will retrieve the information from Terraform state (e.g.: tfstate) and install the tool on the admin server

```console
ansible-playbook -i ../inventory.ini playbook-install-tools-auto.yml
```
