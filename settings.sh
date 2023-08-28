################################################
# Fill out the following variables to configure
# beside the title and descriptions for the YAML files, do not quote the paramters



#################################################
# Google Cloud Project

#set config file paths
export ESP_CONFIG_FILE_PATH=config/esp-config.yaml
export API_CONFIG_FILE_PATH=config/api-config.yaml

# GCP Project ID
export PROJECT_ID=

# Region
export REGION=us-central1

# Service Account
# Should be the default compute service account
export SERVICE_ACCOUNT=

# Name for Cloud Run ESP service. This can be any name you want. lower Case.
export CLOUD_RUN_SERVICE_NAME=

#ESP Version, generally not needed to change this
export ESP_VERSION=2.44.0

#Set api names. These can be any name you want.
export API_NAME=
export API_CONFIG_NAME=
export API_GATEWAY_NAME=

# ESP Config File Paramters
export ESP_TITLE=""
export ESP_DESCRIPTION=""
export CLOUD_FUNCTION_URL=https://sample-function-uc.a.run.app

# API Config File Paramters
export API_TITLE=""
export API_DESCRIPTION=""

#################################################
# Uninstall parameters. Only needed if you want to uninstall the API Gateway and ESP. Otherwise, leave blank.
export UNINSTALL_ESP_ENDPOINT_URL=  #Cloud Run host URL without https://
export UNINSTALL_CLOUD_RUN_SERVICE=https://${UNINSTALL_ESP_ENDPOINT_URL} #Cloud Run host URL with https://

