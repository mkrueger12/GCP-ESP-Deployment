#!/bin/bash

# Uninstall script for ACN Doc Chat
#
# This script will uninstall the components that were installed by the install.sh script.

# ----------------------------------------------------------------------------
# Google Cloud API Gateway

set -e

# Echo but with a nice arrow and in bright green.
function _echo() {
  echo -e "\033[1;37m➜ \033[1;32m$1\033[0m"
}

function delete_api_gateway() {
  _echo "Deleting API Gateway..."

  gcloud api-gateway gateways delete ${API_GATEWAY_NAME} --project=${PROJECT_ID} --location=${REGION} --quiet
  gcloud api-gateway api-configs delete ${API_CONFIG_NAME} --api=${API_NAME} --project=${PROJECT_ID} --quiet
  gcloud api-gateway apis delete ${API_NAME} --project=${PROJECT_ID} --async --quiet

  _echo "API Gateway Deleted..."
}

# ----------------------------------------------------------------------------
# Google Cloud Run ESP

function delete_esp() {
  _echo "Deleting ESP..."

  gcloud services disable ${UNINSTALL_ESP_ENDPOINT_URL} --project=${PROJECT_ID} --quiet
  gcloud endpoints services delete ${UNINSTALL_ESP_ENDPOINT_URL} --project=${PROJECT_ID} --async --quiet
  gcloud run services delete ${CLOUD_RUN_SERVICE_NAME} --platform managed --project=${PROJECT_ID} --region=${REGION} --async --quiet

  _echo "ESP Deleted..."
}

##############################################################################
# MAIN UNINSTALLER

_echo "Begin uninstall!"

SETTINGS=./settings.sh
source ${SETTINGS}

delete_api_gateway
delete_esp

_echo "Uninstall completed!"
