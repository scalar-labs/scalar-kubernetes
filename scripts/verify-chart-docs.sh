#!/usr/bin/env bash

set -e -o pipefail; [[ -n "$DEBUG" ]] && set -x

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"

docs="${SCRIPT_ROOT}/../charts/stable/**/README.md"
"${SCRIPT_ROOT}/update-chart-docs.sh"

set +e
git diff --no-patch --exit-code "$docs"
exit_code="$?"
set -e

# Discard changes
git checkout -- "$docs"

if [[ "$exit_code" != 0 ]]; then
  echo
  echo "Run ./scripts/update-chart-docs.sh"
  exit 1
fi
# vim: ai ts=2 sw=2 et sts=2 ft=sh
