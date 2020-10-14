# How to Deploy Scalar DL on Azure AKS

This example will deploy a simple AKS Cluster environment in the Japaneast region with your Azure account. If you want to use another region or store the tfstate on Azure you need to update `examples.tfvars` of network module.

## Prerequisites

* Terraform >= 0.12.x
* Ansible >= 2.9
* Python lib jmespath >= latest (`pip install jmespath`)
* Azure CLI
* ssh-agent with a private key

You also need to have enough permissions to deploy the Kubernetes cluster with Terraform. Please see [Cloud Privileges for scalar-k8s](./CloudPrivileges.md#Azure) for more detail.

## Architecture

![image](images/architecture-aks.png)

## What is created

* An Azure VPC associated with Resource Group
* An AKS cluster with two Kubernetes node pools
* 3 Envoy Kubernetes Pods with a network load balancer
* 3 Scalar DL Kubernetes Pods
* 1 Prometheus operator to collect metrics inside Kubernetes
* 1 FluentBit Pod on each node to collect Kubernetes log
* DNS Zone for internal host lookup
* 3 Cassandra instances
* 1 Cassy instance
* 1 Reaper instance
* 1 Bastion instance with a public IP
* 1 Monitor instance to collect metrics and logs

## How to deploy

### Configure an Azure credential

```console
az login
```

### Create network resources

```console
# Please update `/path/to/local-repository` before running the command.
$ export SCALAR_K8S_HOME=/path/to/local-repository
$ cd ${SCALAR_K8S_HOME}/modules/azure/network

# Generate a test key-pair
$ ssh-keygen -b 2048 -t rsa -f ./example_key -q -N ""
$ chmod 400 example_key

# You need to add the key to your ssh agent
$ ssh-add example_key

# Create an environment and bastion server
$ terraform init

# Update the "name" to an unique value for your deployment inside "example.tfvars"
$ terraform apply -var-file example.tfvars
```

Note that the current version uses [the network module](https://github.com/scalar-labs/scalar-terraform/tree/master/modules/azure/network) of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform).  It uses the master branch but it would probably need to be changed if you deploy it in your production environment.

### Create Cassandra resources

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/cassandra

# Create the cassandra cluster
$ terraform init
$ terraform apply -var-file example.tfvars
```

Please make sure to start all the Cassandra nodes since Cassandra doesn't start on the initial boot by default.

Note that the current version uses [the cassandra module](https://github.com/scalar-labs/scalar-terraform/tree/master/modules/azure/cassandra) of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform). It uses the master branch but it would probably need to be changed if you deploy it in your production environment.

### Create Kubernetes cluster

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/kubernetes

# Create the Kubernetes cluster
$ terraform init
$ terraform apply -var-file example.tfvars
```

For more information about the variable in `example.tfvars`, please refer to [kubernetes modules](../modules/azure/kubernetes/README.md)

### Create Monitor resources

The Scalar deployment tools include a Prometheus metrics server, Grafana data visualization server, and Alertmanager server for cassandra cluster, cassy, and bastion server

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/monitor

# Create the monitor server for cassandra modules and log collection
$ terraform init
$ terraform apply -var-file example.tfvars
```
Note that the current version uses [the monitor module](https://github.com/scalar-labs/scalar-terraform/tree/master/modules/azure/monitor) of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform/). It uses the master branch but it would probably need to be changed if you deploy it in your production environment.
