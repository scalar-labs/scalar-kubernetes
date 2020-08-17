# Scalar Kubernetes

Scalar Kubernetes is a set of Terraform modules, Kubernetes manifest files, and Ansible scripts that can be used to orchestrate a Scalar DLT network in a cloud environment. The Terraform modules are mainly used to create Cassandra nodes and a Kubernetes cluster.

The manifest files are used to deploy stateless Scalar DL containers such as scalar-ledger and Envoy on the Kubernetes cluster. The Ansible scripts are used to install required tools such as kubectl on bastion and manage the Kubernetes applications.

Note that the current version only supports the deployment of a single Scalar DLT cluster in Azure. It does *NOT* support multi-cluster Scalar DLT deployment, where multiple ledgers are managed independently through Scalar DM and other cloud providers.

## Requirements

* [Terraform >= 0.12.x](https://www.terraform.io/downloads.html)
* [Ansible >= 2.9.x](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* Cloud provider CLI tools such as `az` (they need to be configured with credentials)
* Docker Engine (with access to `scalarlabs/scalar-ledger` docker registry)
  * `scalar-ledger` is available to only our partners and customers at the moment.

## Getting Started

To get started with simple deployment, please follow [the getting started guide](docs/GettingStarted.md). This guide will cover how to build an environment with the tool.

## Project Overview

The repo is divided into two sections, operation. All terraform modules are in [scalar-terraform](https://github.com/scalar-labs/scalar-terraform); only the Kubernetes module is maintained in this project.

### [Operation](./operation)

The operation directory contains Ansible Playbooks and Kubernetes manifests to help you install and deploy pods on the Kubernetes cluster.

## Future Work

* Support other cloud providers like AWS or GKE
