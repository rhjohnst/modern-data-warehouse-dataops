#!/bin/bash

#rsj my ENV variables - need to setup config that is not published to git, for global variables to protect info
export ENV_NAME='dev'
export PROJECT='mdwddbr'
export AZURE_SUBSCRIPTION_ID=''
export AZURE_RESOURCE_GROUP_LOCATION='centralus'

# initialise optional variables.

DEPLOYMENT_PREFIX=${DEPLOYMENT_PREFIX:-}
if [ -z "$DEPLOYMENT_PREFIX" ]
then 
    export DEPLOYMENT_PREFIX="$(random_str 5)"
    echo "No deployment id [DEPLOYMENT_PREFIX] specified, defaulting to $DEPLOYMENT_PREFIX"
fi

AZURE_RESOURCE_GROUP_LOCATION=${AZURE_RESOURCE_GROUP_LOCATION:-}
if [ -z "$AZURE_RESOURCE_GROUP_LOCATION" ]
then    
    export AZURE_RESOURCE_GROUP_LOCATION="westus"
    echo "No resource group location [AZURE_RESOURCE_GROUP_LOCATION] specified, defaulting to $AZURE_RESOURCE_GROUP_LOCATION"
fi

AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID:-}
if [ -z "$AZURE_SUBSCRIPTION_ID" ]
then
    export AZURE_SUBSCRIPTION_ID=$(az account show --output json | jq -r '.id')
    echo "No Azure subscription id [AZURE_SUBSCRIPTION_ID] specified. Using default subscription id."
fi



