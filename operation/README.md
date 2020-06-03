# Operation

In this directory, you will find mainly Ansible playbooks to install or deploy an application on Kubernetes cluster.

## Structure

* roles directory: hold ansible roles
* tmp directory: for temporary files from ansible
* at this root directory, you will find playbook-*.yml that will cover specify need

## Playbook collection

* Ansible playbook-install-tools.yml: The goal is to install kubectl, helm dependency on the admin server. the complete guide is located [here](../docs/PrepareBastionTool.md)
