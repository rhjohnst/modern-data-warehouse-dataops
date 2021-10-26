#!/bin/bash

# Access granted under MIT Open Source License: https://en.wikipedia.org/wiki/MIT_License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, # and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions 
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace # For debugging

#rsj - setting environment variable for running in bash when we try to create/assign service principle
#ref: https://github.com/Azure/azure-cli/blob/dev/doc/use_cli_with_git_bash.md#auto-translation-of-resource-ids
export MSYS_NO_PATHCONV='1'

#rsj - deleted parameter count 'if' statement and setting up environment variables here
project="tempevnt4"
envname="apps"

app_service_plan_name="mdwdops-$project-$envname-spl"
RESOURCE_GROUP_NAME="mdwdops-$project-$envname-rg"
APPS_STORAGE_ACCOUNT_NAME="mdwdopsst$envname$project"
APPS_CONTAINER_NAME="mdwdops-$project-$envname-ctr"
KEYVAULT_NAME="mdwdops-kv--$project-$envname"
LOCATION="usgovvirginia"

echo "app_service_plan_name=$app_service_plan_name"
echo "RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME"
echo "APPS_STORAGE_ACCOUNT_NAME=$APPS_STORAGE_ACCOUNT_NAME"
echo "APPS_CONTAINER_NAME=$APPS_CONTAINER_NAME"
echo "KEYVAULT=$KEYVAULT_NAME"
echo "LOCATION=$LOCATION"

# Create the resource group
az group create -n "$RESOURCE_GROUP_NAME" -l "$LOCATION"

# Create application service plan - defaulting to free service plan for now, sku B1 is default
az appservice plan create --name $app_service_plan_name --resource-group $RESOURCE_GROUP_NAME 

## WORKS TO HERE ##
# Create web application resource
az webapp create --name "mdwdops-$project-app" --plan $app_service_plan_name --resource-group $RESOURCE_GROUP_NAME

# Create the storage account for dev (hot storage)
az storage account create -g "$RESOURCE_GROUP_NAME" -l "$LOCATION" \
  --name "${APPS_STORAGE_ACCOUNT_NAME}d" \
  --sku Standard_LRS \
  --encryption-services blob \
  --kind StorageV2

# Retrieve the storage account key for dev
ACCOUNT_KEY_DEV=$(az storage account keys list --resource-group "$RESOURCE_GROUP_NAME" \
    --account-name "${APPS_STORAGE_ACCOUNT_NAME}d" --query [0].value -o tsv)

echo "ACCOUNT_KEY_DEV=$ACCOUNT_KEY_DEV"

#rsj - breaks here
# Create a storage container (for the apps) for dev
az storage container create --name "$APPS_CONTAINER_NAME" \
    --account-name "${APPS_STORAGE_ACCOUNT_NAME}" \
    --account-key "$ACCOUNT_KEY_DEV"

# Create an Azure KeyVault
az keyvault create -g "$RESOURCE_GROUP_NAME" -l "$LOCATION" --name "$KEYVAULT_NAME"

# Store theStorage Key into KeyVault
az keyvault secret set --name apps-storage-key-dev --value "$ACCOUNT_KEY_DEV" --vault-name "$KEYVAULT_NAME"

# Create Service Principal
# echo "Creating Service Principal"
# SUBSCRIPTION_ID=$(az account show --query id --output tsv)
# #error - taking out the scope
# #ad=$(az ad sp create-for-rbac --role Contributor --query '[appId, password]' --output tsv)
# ad=$(az ad sp create-for-rbac --role Contributor --scopes /subscriptions/"$SUBSCRIPTION_ID" --query '[appId, password]' --output tsv)

# APP_ID=$(echo "${ad}" | head -1)
# SP_PASSWD=$(echo "${ad}" | tail -1)
# TENANT_ID=$(az ad sp show --id "$APP_ID" --query appOwnerTenantId --output tsv)

# # Store credentials to be used by Functions
# echo "Storing Service Principal"
# az keyvault secret set --name tf-subscription-id --value "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME"
# az keyvault secret set --name tf-sp-id --value "$APP_ID" --vault-name "$KEYVAULT_NAME"
# az keyvault secret set --name tf-sp-secret --value "$SP_PASSWD" --vault-name "$KEYVAULT_NAME"
# az keyvault secret set --name tf-tenant-id --value "$TENANT_ID" --vault-name "$KEYVAULT_NAME"
# az keyvault secret set --name tf-storage-name --value "${APPS_STORAGE_ACCOUNT_NAME}dev" --vault-name "$KEYVAULT_NAME"

# Create app insights  ---- VALIDATE
appInsightsName = "funcsmsi-$envname-$project"
az resource create 
  -g $RESOURCE_GROUP_NAME -n $appInsightsName 
  --resource-type "Microsoft.Insights/components" 
  --properties '{\"Application_Type\":\"web\"}'

# Create function ---- VALIDATE
$functionAppName = "funcs-$envname-$project-DeviceIdFilter"

az functionapp create \
  -n $functionAppName \
  --storage-account $storageAccountName \
  --consumption-plan-location $location \
  --app-insights $appInsightsName \
  --runtime dotnet \
  -g $resourceGroup

# # Deploy our function app code ---- VALIDATE
# # publish the code
# dotnet publish -c Release
# $publishFolder = "functions/TemperatureEvents/publish"

# #$publishFolder = "FunctionsDemo/bin/Release/netcoreapp2.1/publish"

# # create the zip ---- VALIDATE
# $publishZip = "publish.zip"
# if(Test-path $publishZip) {Remove-item $publishZip}
# Add-Type -assembly "system.io.compression.filesystem"
# [io.compression.zipfile]::CreateFromDirectory($publishFolder, $publishZip)

# # deploy the zipped package ---- VALIDATE
# az functionapp deployment source config-zip `
#  -g $resourceGroup -n $functionAppName --src $publishZip

# # configure application settings ---- VALIDATE
# az functionapp config appsettings set -n $functionAppName -g $resourceGroup `
#     --settings "MySetting1=Hello" "MySetting2=World"

# # set the daily quota for development .... no need to experience a Denial of Wallet on yourself
# az functionapp update -g $resourceGroup -n $functionAppName `
#     --set dailyMemoryTimeQuota=50000

EOF
