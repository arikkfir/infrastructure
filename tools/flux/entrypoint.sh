#!/usr/bin/env bash

[[ -z "${CLUSTER_NAME}" ]] || (echo "CLUSTER_NAME is missing" >&2 && exit 1)
[[ -z "${CLUSTER_ZONE}" ]] || (echo "CLUSTER_ZONE is missing" >&2 && exit 1)
[[ -z "${GITHUB_TOKEN}" ]] || (echo "GITHUB_TOKEN is missing" >&2 && exit 1)
[[ -z "${REPO_OWNER}" ]] || (echo "REPO_OWNER is missing" >&2 && exit 1)
[[ -z "${REPO_NAME}" ]] || (echo "REPO_NAME is missing" >&2 && exit 1)
[[ -z "${REPO_BRANCH}" ]] || (echo "REPO_BRANCH is missing" >&2 && exit 1)
[[ -z "${REPO_PATH}" ]] || (echo "REPO_PATH is missing" >&2 && exit 1)
[[ -z "${NAMESPACE}" ]] || (echo "NAMESPACE is missing" >&2 && exit 1)
[[ "${MODE}" == "apply" ]] || export MODE="preview"

set -euo pipefail

gcloud container clusters get-credentials "--zone=${CLUSTER_ZONE}" "${CLUSTER_NAME}"
if [[ "${MODE}" == "apply" ]]; then
  if [[ "$(kubectl get namespaces | grep -c flux-system)" == "0" ]]; then
    flux bootstrap github \
      "--personal" \
      "--owner=${REPO_OWNER}" \
      "--repository=${REPO_NAME}" \
      "--branch=${REPO_BRANCH}" \
      "--path=${REPO_PATH}" \
      "--namespace=${NAMESPACE}"
  else
    echo "Flux appears to be already installed, verifying..."
    flux check "--namespace=${NAMESPACE}"
  fi
else
  echo flux bootstrap github \
    "--personal" \
    "--owner=${REPO_OWNER}" \
    "--repository=${REPO_NAME}" \
    "--branch=${REPO_BRANCH}" \
    "--path=${REPO_PATH}" \
    "--namespace=${NAMESPACE}"
fi
