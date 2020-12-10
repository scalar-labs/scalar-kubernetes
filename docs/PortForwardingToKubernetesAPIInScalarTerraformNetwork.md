# How to do port-forwarding to Kubnernetes API in scalar-terraform network

This document explains how to create an SSH port-forwarded connection to the Kubernetes API in the scalar-terraform network.

The Kubernetes cluster created with scalar-terraform doesn't expose the API server to public. You will need an SSH connection to the bastion host that does port-forwarding to the Kubernetes API to operate from your local machine.

After following the doc, you will get an ssh.cfg file to establish an SSH connection to the bastion host and a kube_config file for accessing the Kubernetes API on the connection.

## Requirement

* Have completed [How to create Azure AKS with scalar-terraform](./AKSScalarTerraformDeploymentGuide.md)

## Create kube_config file

You can get the kube_config file from `terraform output` of the `kubernetes` module.

```console
cd ${SCALAR_K8S_HOME}/modules/azure/kubernetes/
terraform output kube_config > ~/.kube/config
```

Please replace the `server` in the output with `https://localhost:7000` as follows. `7000` is the default local port number which is forwarded to the Kubernetes API.

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1...
    server: https://localhost:7000 # <- Replace this line
  name: scalar-kubernetes
contexts:
...
```

## Create ssh.cfg file

The following command will generate an `ssh.cfg` to connect to the bastion. It contains `LocalForward 7000` to the Kubernetes API so that you can access the API from your local machine with the kube_config file created in the above section.

```console
cd ${SCALAR_K8S_HOME}/modules/azure/kubernetes
terraform output k8s_ssh_config > ${SCALAR_K8S_CONFIG_DIR}/ssh.cfg
```

## Enable port-forwarding

When you commnunicate with the Kubernetes API from your local machine, please keep a terminal open that runs the SSH port-fowarding with the following command.

```console
cd ${SCALAR_K8S_CONFIG_DIR}
ssh -F ssh.cfg bastion
```
