[![AWS Kubernetes Integration Test](https://github.com/scalar-labs/scalar-terratest/workflows/Integration-test-with-terratest-for-AWS-Kubernetes/badge.svg?branch=master)](https://github.com/scalar-labs/scalar-terratest/actions)

[![Azure Kubernetes Integration Test](https://github.com/scalar-labs/scalar-terratest/workflows/Integration-test-with-terratest-for-Azure-Kubernetes/badge.svg?branch=master)](https://github.com/scalar-labs/scalar-terratest/actions)

# Scalar Kubernetes

Scalar Kubernetes is a set of Helm charts and Ansible playbooks that can be used to orchestrate a Scalar DLT network in a cloud environment. The Helm charts are used to deploy stateless Scalar DL containers such as scalar-ledger and Envoy on the Kubernetes cluster. The Ansible playbooks are used to install required tools such as kubectl on bastion and manage the Kubernetes applications.

Note that the current version only supports the deployment of a single Scalar DL cluster. It does *NOT* support multi-cluster Scalar DL deployment, where multiple ledgers are managed independently through Scalar DL Ordering.```


## Requirements

* [Ansible >= 2.9.x](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* Cloud provider CLI tools such as `az` (they need to be configured with credentials)
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.

## Getting Started

To get started with simple deployment, please follow [the getting started guide](docs/GettingStarted.md). This guide will cover how to build an environment with the tool.

## Repository Overview

The repo is divided into two components: Helm charts and Ansible playbooks.

### [Charts](./charts)

The `charts` directory contains Helm charts to deploy Scalar DL on the Kubernetes cluster.

### [Playbooks](./playbooks)

The `playbooks` directory contains Ansible playbooks to help you to install the required tools such as `kubectl` and `helm` on a bastion node, and to install the charts on a Kubernetes cluster.


## Future Work

* Support other cloud providers like GKE
