# Scalar Kubernetes - Cloud Native

Scalar Kubernetes is a set of Terraform modules and operation scripts that can be used to orchestrate a Scalar DLT network in a cloud on top of Kubernetes. Only Azure is currently supported. Note that the current version only supports deployment of single Scalar DLT cluster; that is, it does not support multi-cluster Scalar DLT deployment where multiple ledgers are managed independently through Scalar DM.

Kubernetes (K8s) is a container management platform that aims to provide automating deployment, scaling, and operations of application containers across clusters of hosts.

## Requirements

* [Terraform >= 0.12.x](https://www.terraform.io/downloads.html)
* [Ansible >= 2.9.x](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* Cloud provider CLI tools such as `aws` and `az` (they need to be configured with credentials)
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.

## Getting Started

To get started with simple deployment, please follow [the getting started guide](docs/GettingStarted.md). This guide will cover how to build an environment with the tool.

## Project Overview

The repo is divided into two sections, modules, operation.

### [Modules](./modules)

The modules directory is where the terraform modules are located. Most of the terraform modules are related to [scalar-terraform](https://github.com/scalar-labs/scalar-terraform); only the Kubernetes module is maintained in this project.

### [Operation](./operation)

The operation directory is where Ansible Playbooks are located to install and deploy configuration and Pods on the Kubernetes cluster .

## Future Work

* Support other cloud providers like AWS or GKE
