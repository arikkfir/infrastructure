#!/usr/bin/env bash

if [[ -z "${MODE}" || "${MODE}" != "apply" ]]; then
  MODE=preview
fi
[[ "${MODE}" != "apply" || -n "${CLUSTER_NAME}" ]] || (echo "CLUSTER_NAME is missing" >&2 && exit 1)
[[ "${MODE}" != "apply" || -n "${CLUSTER_ZONE}" ]] || (echo "CLUSTER_ZONE is missing" >&2 && exit 1)

set -exuo pipefail

if [[ "${MODE}" == "apply" ]]; then
  gcloud container clusters get-credentials --zone "${CLUSTER_ZONE}" "${CLUSTER_NAME}"
  kustomize build | kubectl apply -f -
else
  kustomize build
fi
