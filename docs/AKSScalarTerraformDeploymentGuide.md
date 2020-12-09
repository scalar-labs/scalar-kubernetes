# How to Create Azure AKS with scalar-terraform

This document shows how to create Azure Kubernetes Service (AKS) along with a virtual network, a bastion host, and database resources using Terraform scripts.

The Terraform scripts for creating resources with [scalar-terraform](https://github.com/scalar-labs/scalar-terraform) are all stored in `${SCALAR_K8S_HOME}/modules`.

## Create network resources

```console
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

## Create Kubernetes cluster

* If you use Cosmos DB, please set `use_cosmosdb` to `true` in `example.tfvars` before you run `terraform apply`

    ```hcl
    use_cosmosdb = true
    ```

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/kubernetes

# Create the Kubernetes cluster
$ terraform init
$ terraform apply -var-file example.tfvars
```

For more information about the variable in `example.tfvars`, please refer to [kubernetes modules](../modules/azure/kubernetes/README.md)

## Create database resources

Deploy either a Cassandra cluster or a Cosmos DB account, depending on your choice.

### Cassandra

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/cassandra

# Create the cassandra cluster
$ terraform init
$ terraform apply -var-file example.tfvars
```

Note that the current version uses [the cassandra module](https://github.com/scalar-labs/scalar-terraform/tree/master/modules/azure/cassandra) of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform). It uses the master branch but it would probably need to be changed if you deploy it in your production environment.

### Cosmos DB

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/cosmosdb

# Create Cosmos DB account
$ terraform init
$ terraform apply
```

Note that the current version uses [the cosmosdb module](https://github.com/scalar-labs/scalar-terraform/tree/master/modules/azure/cosmosdb) of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform). It uses the master branch but it would probably need to be changed if you deploy it in your production environment.

## Create Monitor resources

The Scalar deployment tools include a Prometheus metrics server, Grafana data visualization server, and Alertmanager server for cassandra cluster, cassy, and bastion server

* If you use Cosmos DB, please remove `cassandra` from `targets` in `example.tfvars` since the monitor module is not able to monitor Cosmos DB.

    ```hcl
    targets = []
    ```

```console
$ cd ${SCALAR_K8S_HOME}/modules/azure/monitor

# Create the monitor server for cassandra modules and log collection
$ terraform init
$ terraform apply -var-file example.tfvars
```

Note that the current version uses [the monitor module](https://github.com/scalar-labs/scalar-terraform/tree/master/modules/azure/monitor) of [scalar-terraform](https://github.com/scalar-labs/scalar-terraform/). It uses the master branch but it would probably need to be changed if you deploy it in your production environment.

## Next Steps

* Please follow the steps in [How to install Kubernetes CLI and Helm on the bastion](./PrepareBastionTool.md) to prepare tools needed in the bastion host, then go to [How to deploy Scalar DL on Kubernetes with Ansible](./DeployScalarDLAnsible.md) to do the deployment.
* Alternatively, you can do the deployment process by running Helm charts directly from your local machine. Please refer to [Deploy Scalar DL with Helm](./DeployScalarDLHelm.md) for details.
