# Experimental features

Collection of ansible script to deploy automatically the env in azure

## Setup

this script is to spin up TF modules (network, kubernetes, cassandra) in azure

```console
ansible-playbook -i inventory.ini setup.yaml
```

## Teardown

this script is to un-deploy TF modules (network, kubernetes, cassandra) in azure

```console
ansible-playbook -i inventory.ini teardown.yaml
```