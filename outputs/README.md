# Outputs and configurations

default configuration for operation directory

## Create your own outputs directory

Create a directory to store your `inventory.ini`, `kube_config` and `ssh.cfg`. if you decide to not use the outputs directory you need to copy the `envoy-custom-values.yaml` and `ledger-custom-values.yaml` files into your own chosen directory.

```
$ export SCALAR_K8S_OUTPUT_DIRECTORY=../outputs
```

If you use your own directory outside of the project

```
# Please update `/path/to/local-repository-outputs` before running the command.
$ export SCALAR_K8S_OUTPUT_DIRECTORY=/path/to/local-repository-outputs
```

## Structure

```console
outputs
├── README.md
└── example
    ├── envoy-custom-values.yaml
    ├── inventory.ini
    ├── kube_config
    ├── ledger-custom-values.yaml
    └── ssh.cfg
```
