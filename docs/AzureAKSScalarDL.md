# Azure Scalar DL Example

This example will deploy a simple Scalar DL environment in the Japaneast region with your Azure account. If you want to use another region or store the tfstate on Azure you need to update `backend.tf`, `examples.tfvars` and `remote.tf` of each module.

* This document is for internal use of Scalar DL Terraform modules for Azure. If you are interested in the modules, please take a look at [here](../../modules/azure)

## Prerequisites

* Terraform >= 0.12.x
* Ansible >= 2.9.x
* Azure CLI
* ssh-agent with a private key

## What is created

* An Azure VPC with Resource Group
* An AKS cluster with two node pools
* 3 Envoy Kubernetes Pods with a network load balancer (public)
* 3 Scalar DL Kubernetes Pods
* DNS Zone for internal host lookup
* 3 Cassandra instances
* 1 Cassy instance
* 1 Reaper instance
* 1 Bastion instance with a public IP

## How to deploy

### Configure an Azure credential

```console
az login
```

### Create network resources

```console
cd examples/azure/network

# Generate a test key-pair
ssh-keygen -b 2048 -t rsa -f ./example_key -q -N ""
chmod 400 example_key

# You need to pass the key to your ssh-agent
# If needed start ssh-agent using: eval $(ssh-agent -s)
ssh-add example_key

# Optionally, you may want to create a file named `additional_public_keys` that contains multiple ssh public keys (one key per line) to allow other admins to access nodes created by the following `terraform apply`.
# the file should look like below
# cat examples/azure/network/additional_public_keys
# ssh-rsa AAAAB3Nza..... admin1
# ssh-rsa...... admin2


# Create an environment
terraform init
terraform apply -var-file example.tfvars
```

### Create Cassandra resources

Before creating Cassandra resources with `terraform apply`, you probably need to configure for Cassy to manage backups of Cassandra data.

For Cassy, the first thing you need to do is create a storage account in the same resource group as the network resource created in the previous section and create a blob type container in the storage account.

Then, update `example.tfvars` with the container URL as follows.

```console
cassy = {
  storage_base_uri     = "https://yourstorageaccountname.blob.core.windows.net/your-container-name"
  storage_type         = "azure_blob"
}
```

If you don't need Cassy, you can disable it by setting its `resource_count` to zero.

```console
cassy = {
  resource_count = 0
}
```

For more information on Cassy, please refer to [CassySetup](https://github.com/scalar-labs/scalar-terraform/blob/master/docs/CassySetup.md).

Now it's ready to run the terraform commands:

```console
cd examples/azure/cassandra

terraform init
terraform apply -var-file example.tfvars
```

### Create Kubernetes cluster

```console
cd examples/azure/kubernetes

terraform init
terraform apply -var-file example.tfvars
```

### Setup bastion for Kubernetes

Please refer to [Prepare bastion tooling](./PrepareBastionTool.md)

### Create Scalar DL and Envoy resources

Please refer to [Manual guide](../operation/manifests/README.md)

## Generate outputs

Terraform can output some useful information about your deployment, such as a bastion public, internal IP addresses, and ssh config that you can use to access instances. The ssh config assumes that the private key for an environment is added to your ssh-agent.

### Network

```console
$ terraform output
bastion_ip = bastion-example-k8s-azure-fpjzfyk.eastus.cloudapp.azure.com
bastion_provision_id = 2467232388962733384
dns_zone_id = internal.scalar-labs.com
image_id = CentOS
internal_domain = internal.scalar-labs.com
location = East US
network_cidr = 10.42.0.0/16
network_id = /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/example-k8s-azure-fpjzfyk/providers/Microsoft.Network/virtualNetworks/example-k8s-azure-fpjzfyk
network_name = example-k8s-azure-fpjzfyk
private_key_path = /path/to/local-repository/scalar-k8s/examples/azure/network/example_key
public_key_path = /path/to/local-repository/scalar-k8s/examples/azure/network/example_key.pub
ssh_config = Host *
User centos
UserKnownHostsFile /dev/null
StrictHostKeyChecking no

Host bastion
HostName bastion-example-k8s-azure-fpjzfyk.eastus.cloudapp.azure.com
LocalForward 8000 monitor.internal.scalar-labs.com:80

Host *.internal.scalar-labs.com
ProxyCommand ssh -F ssh.cfg bastion -W %h:%p

subnet_map = {
  "cassandra" = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/example-k8s-azure-fpjzfyk/providers/Microsoft.Network/virtualNetworks/example-k8s-azure-fpjzfyk/subnets/cassandra"
  "private" = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/example-k8s-azure-fpjzfyk/providers/Microsoft.Network/virtualNetworks/example-k8s-azure-fpjzfyk/subnets/private"
  "public" = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/example-k8s-azure-fpjzfyk/providers/Microsoft.Network/virtualNetworks/example-k8s-azure-fpjzfyk/subnets/public"
  "scalardl_blue" = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/example-k8s-azure-fpjzfyk/providers/Microsoft.Network/virtualNetworks/example-k8s-azure-fpjzfyk/subnets/scalardl_blue"
  "scalardl_green" = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/example-k8s-azure-fpjzfyk/providers/Microsoft.Network/virtualNetworks/example-k8s-azure-fpjzfyk/subnets/scalardl_green"
}
user_name = centos
```

### Cassandra

```console
terraform output
cassandra_provision_ids = [
  "4019088576544490630",
  "656319024837932240",
  "2469094098071954264",
]
cassandra_resource_count = 3
cassandra_start_on_initial_boot = false
```

### Kubernetes

Kubernetes credential can be found with `terraform output kube_config`, see below.

```yml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1...
    server: https://scalar-k8s-c1eae570.fdc2c430-cd60-4952-b269-28d1c1583ca7.privatelink.eastus.azmk8s.io:443
  name: scalar-kubernetes
contexts:
- context:
    cluster: scalar-kubernetes
    user: clusterUser_example-k8s-azure-znmhbo_scalar-kubernetes
  name: scalar-kubernetes
current-context: scalar-kubernetes
kind: Config
preferences: {}
users:
- name: clusterUser_example-k8s-azure-znmhbo_scalar-kubernetes
  user:
    client-certificate-data: LS0tLS1C....
    client-key-data: LS0tLS...
    token: 48fdda...
```

## How to destroy

```console
# Make sure to do this after used !!!
terraform destroy --var-file example.tfvars
```

Note: Don't forget to `terraform destroy` to the environment you created after used.

Please check out [Scalar DL Getting Started](https://scalardl.readthedocs.io/en/latest/getting-started/) to understand how to interact with the environment.
