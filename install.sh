#!/bin/bash

# Install script for API Gateway and ESP deployment
#
##############################################################################

set -e

# Echo but with a nice arrow and in bright green.
function _echo() {
  echo -e "\033[1;37m➜ \033[1;32m$1\033[0m"
}

# ----------------------------------------------------------------------------
# Deploys the extensible service proxy (ESP) to Cloud Run.

function deploy_esp(){

  _echo "Deploying ESP. This may take several minutes."

  gcloud config set run/region REGION #set region

  echo ${CLOUD_RUN_SERVICE_NAME}

  gcloud run deploy ${CLOUD_RUN_SERVICE_NAME} \
    --image="gcr.io/cloudrun/hello" \
    --platform managed \
    --no-allow-unauthenticated \
    --project=${PROJECT_ID} \
    --region=${REGION}


  ESP_HOST=$(gcloud run services describe ${CLOUD_RUN_SERVICE_NAME} --project=${PROJECT_ID} --region=${REGION} --format='value(status.url)')

  ESP_HOST=${ESP_HOST#https://} # Remove the https:// prefix from the ESP host URL

  echo ${ESP_HOST}

  # add the ESP host to the ESP config file
  sed -i "s|host: ''|host: ${ESP_HOST}|g" ${ESP_CONFIG_FILE_PATH}

  gcloud endpoints services deploy ${ESP_CONFIG_FILE_PATH} --project ${PROJECT_ID} # Deploy the configuration for Cloud Endpoints service using the specified ESP configuration YAML file

  ESP_ENDPOINT_URL=https://${ESP_HOST} # Retrieve the service name (URL) of the deployed Cloud Endpoints service

  sed -i "s|address: ''|address: ${ESP_ENDPOINT_URL}|g" ${API_CONFIG_FILE_PATH} # Replace the placeholder address in the API configuration file with the actual ESP endpoint URL

  ESP_ENDPOINT_CONFIG_ID=$(gcloud endpoints configs list --service=${ESP_HOST} --format="value(id)" --limit=1) # Retrieve the configuration ID for the deployed ESP endpoint service

  # Enable the required services for Cloud Endpoints and Cloud Run
  gcloud services enable servicemanagement.googleapis.com
  gcloud services enable servicecontrol.googleapis.com
  gcloud services enable endpoints.googleapis.com
  gcloud services enable ${ESP_HOST} # Enable the ESP endpoint service using its service URL

  chmod +x gcloud_build_image

  ./gcloud_build_image -s ${ESP_HOST} -c ${ESP_ENDPOINT_CONFIG_ID} -p ${PROJECT_ID} -v ${ESP_VERSION}

  gcloud run deploy ${CLOUD_RUN_SERVICE_NAME} \
  --image="gcr.io/${PROJECT_ID}/endpoints-runtime-serverless:${ESP_VERSION}-${ESP_HOST}-${ESP_ENDPOINT_CONFIG_ID}" \
  --platform managed \
  --no-allow-unauthenticated \
  --project=${PROJECT_ID} \
  --region=${REGION}

  _echo "ESP Endpoint Deployed Successfully..."

  }


function deploy_api(){

  _echo "Deploying ${API_NAME} Gateway in project ${PROJECT_ID}. This may take several minutes."

  gcloud api-gateway apis create ${API_NAME} --project=${PROJECT_ID} --quiet

  gcloud api-gateway api-configs create ${API_CONFIG_NAME} \
    --api=${API_NAME} --openapi-spec=${API_CONFIG_FILE_PATH} \
    --project=${PROJECT_ID} --backend-auth-service-account=${SERVICE_ACCOUNT}

  gcloud api-gateway gateways create ${API_GATEWAY_NAME} \
    --api=${API_NAME} --api-config=${API_CONFIG_NAME} \
    --location=${REGION} --project=${PROJECT_ID}

  _echo "API Gateway Deployed Successfully..."

  }



##############################################################################


_echo "Begin install!"
SETTINGS=./settings.sh
source ${SETTINGS}

#add params to config files
sed -i "s|title: ''|title: '${ESP_TITLE}'|g" ${ESP_CONFIG_FILE_PATH}
sed -i "s|description: ''|description: '${ESP_DESCRIPTION}'|g" ${ESP_CONFIG_FILE_PATH}
sed -i "s|address: ''|address: ${CLOUD_FUNCTION_URL}|g" ${ESP_CONFIG_FILE_PATH}

sed -i "s|title: ''|title: '${API_TITLE}'|g" ${API_CONFIG_FILE_PATH}
sed -i "s|description: ''|description: '${API_DESCRIPTION}'|g" ${API_CONFIG_FILE_PATH}

# Perform install.
deploy_esp
deploy_api