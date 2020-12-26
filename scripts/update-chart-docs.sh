#!/usr/bin/env bash

# This script updates README.md for Helm charts with helm-docs tool.
#
# https://github.com/norwoodj/helm-docs

set -e -o pipefail; [[ -n "$DEBUG" ]] && set -x

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"
docker run --rm -v "${SCRIPT_ROOT}/..:/helm-docs" -u $(id -u) docker.io/jnorwood/helm-docs
# vim: ai ts=2 sw=2 et sts=2 ft=sh
