#!/bin/bash

# check required variables are specified.

#my GIT variables
export GITHUB_REPO='rhjohnst/modern-data-warehouse-devops'
export GITHUB_PAT_TOKEN='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'
export ENV_NAME='dev'

#using MCS Internals subscription
#export RESOURCE_GROUP_NAME='ODIN-file-upload'
#export RESOURCE_GROUP_LOCATION='Central US'
#export AZURE_SUBSCRIPTION_ID='60c4e16f-1b86-45cf-a961-035631ee2924'

#using ArmyCoder MSDN Subscription
export AZURE_SUBSCRIPTION_ID='8e58e140-17ab-4f9a-af30-1da4ae5743e1'
export RESOURCE_GROUP_LOCATION='centralus'



if [ -z $GITHUB_REPO ]
then
    echo "Please specify a github repo using the GITHUB_REPO environment variable in this form '<my_github_handle>/<repo>'. (i.e. 'devlace/mdw-dataops-import')"
    exit 1
fi

if [ -z $GITHUB_PAT_TOKEN ]
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

RESOURCE_GROUP_NAME_PREFIX=${RESOURCE_GROUP_NAME_PREFIX:-}
if [ -z $RESOURCE_GROUP_NAME_PREFIX ]
then
    export RESOURCE_GROUP_NAME_PREFIX="mdwdo-adf-${DEPLOYMENT_ID}"
    echo "No resource group name [RESOURCE_GROUP_NAME_PREFIX] specified, defaulting to $RESOURCE_GROUP_NAME_PREFIX"
fi

RESOURCE_GROUP_LOCATION=${RESOURCE_GROUP_LOCATION:-}
if [ -z $RESOURCE_GROUP_LOCATION ]
then
    export RESOURCE_GROUP_LOCATION="westus"
    echo "No resource group location [RESOURCE_GROUP_LOCATION] specified, defaulting to $RESOURCE_GROUP_LOCATION"
fi

AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID:-}
if [ -z $AZURE_SUBSCRIPTION_ID ]
then
    export AZURE_SUBSCRIPTION_ID=$(az account show --output json | jq -r '.id')
    echo "No Azure subscription id [AZURE_SUBSCRIPTION_ID] specified. Using default subscription id."
fi

AZDO_PIPELINES_BRANCH_NAME=${AZDO_PIPELINES_BRANCH_NAME:-}
if [ -z $AZDO_PIPELINES_BRANCH_NAME ]
then
    export AZDO_PIPELINES_BRANCH_NAME="main"
    echo "No branch name in [AZDO_PIPELINES_BRANCH_NAME] specified. defaulting to $AZDO_PIPELINES_BRANCH_NAME."
fi
