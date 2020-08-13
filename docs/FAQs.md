# Frequently Asked Questions (FAQs)

## Where to start

Follow the guide [How to Deploy Scalar DL on Azure AKS](./ScalarDLonAzureAKS.md)

## How to update Scalar DL

Update the local repository `SCALAR_K8S_HOME` and re-apply the deployment `ansible-playbook -i ${SCALAR_K8S_CONFIG_DIR}/inventory.ini operation/playbook-deploy-scalardl.yml`

More information can be found in [Here](./DeployScalarDL.md)

## Use a different internal domain

Follow the guide [Use a different internal domain](DeployScalarDL.md#use-a-different-internal-domain)

## How to restart a scalar app pods

Please follow the [procedure](./DeployScalarDL.md#How-to-force-restart-a-scalar-app-pods)

## Anything that are not recommended

### Helm delete command

Avoid using helm delete <release_name> for scalardl as it will stop the production.

### Kubectl delete command

Avoid using kubectl delete nodes <node_name>
