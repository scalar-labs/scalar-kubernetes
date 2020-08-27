# Operation

In this directory, you will find Ansible playbooks to install or deploy an application on Kubernetes cluster.

## Structure

* roles directory: hold ansible roles
* at this root directory, you will find playbook-*.yml that will cover specify need

## Playbook collection

* Ansible playbook-install-tools.yml: The goal is to install kubectl and Helm on the admin server. the complete guide is located [here](../docs/PrepareBastionTool.md)
* Ansible playbook-deploy-prometheus.yml: The goal is to deploy Prometheus operator in Kubernetes. the complete guide is located [here](../docs/KubernetesMonitorGuide.md)
* playbook-deploy-fluentbit.yml: The goal is to deploy Fluent bit in Kubernetes. the complete guide is located [here](../docs/K8sLogCollectionGuide.md)
* Ansible playbook-deploy-scalardl.yml: he goal is to deploy Scalar DL in Kubernetes. the complete guide is located [here](../docs/DeployScalarDL.md)
