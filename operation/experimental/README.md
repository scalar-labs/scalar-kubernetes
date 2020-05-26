# Experimental features

Collection of ansible script to deploy automatically the env in azure

## Setup

this script is to spin up TF modules (network, kubernetes, cassandra) in azure

you need to prepare TF_variables_file for each modules before starting this playbook.

```console
ansible-playbook -i ../inventory.ini setup.yaml
```

or if you want to do one per one

```console
ansible-playbook -i ../inventory.ini setup.yaml --step
```

or per modules e.g network, kubernetes, cassandra

```console
ansible-playbook -i ../inventory.ini setup.yaml --tags network,kubernetes
```

## Teardown

this script is to un-deploy TF modules (network, kubernetes, cassandra) in azure

```console
ansible-playbook -i ../inventory.ini teardown.yaml
```

## automatic configuration provisioning

the playbook will go retrieve the info from terraform state (e.g: tfstate) and install the tool on the admin server

```console
ansible-playbook -i ../inventory.ini install-tools-auto.yml
```
