#!/bin/bash
# use kubeval to validate helm generated kubernetes manifest
# based on https://raw.githubusercontent.com/eclipse/packages/master/.github/kubeval.sh

set -o errexit
set -o pipefail

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/master -- charts charts/stable | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"
HELM_VERSION="v2.16.6"
KUBEVAL_VERSION="0.15.0"

# install helm
curl --silent --show-error --fail --location --output get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get
chmod 700 get_helm.sh
./get_helm.sh --version "${HELM_VERSION}"
helm init --client-only

# install kubeval plugins to helm
helm plugin install https://github.com/instrumenta/helm-kubeval

# validate charts
for CHART_DIR in ${CHART_DIRS};do
  echo "kubeval(idating) ${CHART_DIR##charts/} chart..."
  helm kubeval "${CHART_DIR}" -v "${KUBERNETES_VERSION#v}" --strict
done
