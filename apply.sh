#!/usr/bin/env bash

set -eu -o pipefail

# Download shared resources
gsutil cp gs://arikkfir-devops/secrets/deployer-sa-key.json.enc ./

# Decrypt resources
gcloud kms decrypt --keyring=global --location=global --key=deploy --ciphertext-file=deployer-sa-key.json.enc --plaintext-file=deployer-sa-key.json
gcloud kms decrypt --keyring=global --location=global --key=deploy --ciphertext-file=secrets.auto.tfvars.enc --plaintext-file=secrets.auto.tfvars

# Switch to the Deployer service account
gcloud auth activate-service-account --key-file=deployer-sa-key.json

# Invoke Terraform
GOOGLE_CREDENTIALS=./deployer-sa-key.json terraform init
GOOGLE_CREDENTIALS=./deployer-sa-key.json terraform plan
[[ 1==1 ]] && exit 1
GOOGLE_CREDENTIALS=./deployer-sa-key.json terraform apply -auto-approve
gcloud container clusters get-credentials --zone=europe-west1-b devops

###################################
# DEVOPS CLUSTER
###################################
export ALERTMANAGER_SLACK_URL=$(terraform output -json alertmanager_slack_url | jq -j '.value')
export CLOUDFLARE_EMAIL=$(terraform output -json cloudflare_email | jq -j '.value')
export CLOUDFLARE_TOKEN=$(terraform output -json cloudflare_token | jq -j '.value' | base64)
export CLUSTER_INGRESS_ADDRESS=$(terraform output -json cluster_ingress_address | jq -j '.value')
export ENV_NAME=devops
export GRAFANA_ADMIN_PASSWORD=$(terraform output -json grafana_admin_password | jq -j '.value' | base64)
export GRAFANA_DB_ROOT_PASSWORD=$(terraform output -json grafana_db_root_password | jq -j '.value' | base64)
export GRAFANA_DB_USER_PASSWORD=$(terraform output -json grafana_db_user_password | jq -j '.value' | base64)
export LETSENCRYPT_ACCOUNT_EMAIL=$(terraform output -json letsencrypt_account_email | jq -j '.value')
export LETSENCRYPT_URL=$(terraform output -json letsencrypt_url | jq -j '.value')
export KUBEWATCH_SLACK_TOKEN=$(terraform output -json kubewatch_slack_token | jq -j '.value')
export WHITELISTED_IP_CIDRS=$(terraform output -json whitelisted_cidrs | jq -jc '.value | join(",")')

# common cluster setup
git clone git@github.com:arikkfir/infrastructure-env.git && git checkout 0.0.1
pushd infrastructure-env && ./apply.sh && popd && rm -rf infrastructure-env

# jenkins
cat jenkins.yaml | envsubst | kubectl apply -f -
kubectl wait --timeout=5m --namespace=jenkins --for=condition=Available deploy/master

# spinnaker
cat spinnaker.yaml | envsubst | kubectl apply -f -
kubectl wait --timeout=5m --namespace=spinnaker --for=condition=Available deploy/spin-hal
