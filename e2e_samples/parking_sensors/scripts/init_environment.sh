#!/bin/bash

#rsj  variables
export ENV_NAME='dev'
export AZURE_SUBSCRIPTION_ID=''
export RESOURCE_GROUP_LOCATION='usgovarizona'
export AZURE_LOCATION='usgovarizona'
export DEPLOYMENT_ID='dodl2'
export GITHUB_REPO=''
export GITHUB_PAT_TOKEN='g'

# check required variables are specified.

if [ -z "$GITHUB_REPO" ]
then 
    echo "Please specify a github repo using the GITHUB_REPO environment variable in this form '<my_github_handle>/<repo>'. (ei. 'devlace/mdw-dataops-import')"
    exit 1
fi

if [ -z "$GITHUB_PAT_TOKEN" ]
then 
    echo "Please specify a github PAT token using the GITHUB_PAT_TOKEN environment variable."
    exit 1
fi

# initialise optional variables.

DEPLOYMENT_ID=${DEPLOYMENT_ID:-}
if [ -z "$DEPLOYMENT_ID" ]
then 
    export DEPLOYMENT_ID="$(random_str 5)"
    echo "No deployment id [DEPLOYMENT_ID] specified, defaulting to $DEPLOYMENT_ID"
fi

AZURE_LOCATION=${AZURE_LOCATION:-}
if [ -z "$AZURE_LOCATION" ]
then    
    export AZURE_LOCATION="westus"
    echo "No resource group location [AZURE_LOCATION] specified, defaulting to $AZURE_LOCATION"
fi

AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID:-}
if [ -z "$AZURE_SUBSCRIPTION_ID" ]
then
    export AZURE_SUBSCRIPTION_ID=$(az account show --output json | jq -r '.id')
    echo "No Azure subscription id [AZURE_SUBSCRIPTION_ID] specified. Using default subscription id."
fi

AZDO_PIPELINES_BRANCH_NAME=${AZDO_PIPELINES_BRANCH_NAME:-}
if [ -z "$AZDO_PIPELINES_BRANCH_NAME" ]
then
    export AZDO_PIPELINES_BRANCH_NAME="main"
    echo "No branch name in [AZDO_PIPELINES_BRANCH_NAME] specified. defaulting to $AZDO_PIPELINES_BRANCH_NAME."
fi

AZURESQL_SERVER_PASSWORD=${AZURESQL_SERVER_PASSWORD:-}
if [ -z "$AZURESQL_SERVER_PASSWORD" ]
then 
    export AZURESQL_SERVER_PASSWORD="mdwdo-azsql-SqlP@ss-${DEPLOYMENT_ID}"
    echo "No password for sql server specified, defaulting to $AZURESQL_SERVER_PASSWORD"
fi