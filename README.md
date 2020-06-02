# Scalar Kubernetes - Cloud Native

Kubernetes (K8s) is a container management platform that aims to provide automating deployment, scaling, and operations of application containers across clusters of hosts.

TODO

Note that the current version only supports the deployment of a single Scalar DLT cluster. That is, it does not support multi-cluster Scalar DLT deployment, where multiple ledgers are managed independently through Scalar DM.

## Requirements

* [Terraform >= 0.12.x](https://www.terraform.io/downloads.html)
* [Ansible >= 2.8.x](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* Cloud provider CLI tools such as `aws` and `az` (they need to be configured with credentials)
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.

## Getting Started

To get started with simple deployment, please follow [the getting started guide](docs/GettingStarted.md). This guide will cover how to build an environment with the tool.

## Project Overview

[TODO defined]

## Future Work

[TODO defined]
