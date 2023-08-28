# esp-deployment



## What is this for?

It might be needed to expose certain GCP backend services to the internet as a REST API.
This repo deploys the infrastructure needed to accomplish this while protecting it with an API key.

High-level steps:

1. Deploy Cloud Function with no public access (This step not include in this repo)
2. Deploy ESP to point at the Cloud Run host of Cloud Function
3. Deploy API Gateway to point at ESP
4. Generate API key for API Gateway (not included in this repo)

Docs: https://cloud.google.com/endpoints/docs/openapi/set-up-cloud-run-espv2


## Architecture

![IMAGE_DESCRIPTION](https://cloud.google.com/static/endpoints/docs/images/espv2-serverless-cloud-functions.svg)

## Installation

1. Deploy your cloud function or other backend service.
2. Run `gcloud auth login` in your terminal to authenticate with Google Cloud.
3. Set the path parameters in the YAML files to match your desired API behavior. 
   It is advisable to only change the `paths:` parameters as the install will update the rest of the file.
4. Update the settings in `./settings.sh`
5. Run `./install.sh`. Install will take several minutes.
6. Generate an API key for your API in the Credentials section of the API Gateway console.
   Be sure to allow access to your API by the API key during creation.  [Docs here](https://cloud.google.com/docs/authentication/api-keys#gcloud).

## Uninstall

1. Run `./uninstall.sh`
2. This will remove the API Gateway, ESP host, and ESP endpoint . It will not remove the Cloud Function or associated Cloud Run service.

## YAML Configuration Files

Build your YAML files based in the OpenAPI spec. 
The paths for each YAML file should match. The ESP config file does not need to have the security settings of the API config file.
The ESP is not accessible from the internet by default. Do not update anything in these files outside of the `paths:` section unless you know what you are doing.
The install will handle updating these files.