#!/bin/bash
# use kubeval to validate helm generated kubernetes manifest
# based on https://raw.githubusercontent.com/eclipse/packages/master/.github/kubeval.sh

set -o errexit
set -o pipefail

CHART_DIRS="$(ls charts/stable)"
HELM_VERSION="v3.2.4"

# install helm
curl --silent --show-error --fail --location --output get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get
chmod 700 get_helm.sh
./get_helm.sh --version "${HELM_VERSION}"

# add helm repos to resolve dependencies
helm repo add stable https://charts.helm.sh/stable

# install kubeval plugins to helm
helm plugin install https://github.com/instrumenta/helm-kubeval

# validate charts
for CHART_DIR in ${CHART_DIRS};do
  echo "kubeval(idating) charts/stable/${CHART_DIR} chart..."
  helm kubeval "charts/stable/${CHART_DIR}" -v "${KUBERNETES_VERSION#v}"
done
