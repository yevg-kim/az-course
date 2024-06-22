#!/bin/bash
# For local fiddling purposes
dir="$(dirname "$0")"
source ${dir}/exports.sh
az deployment group create --template-file ${dir}/bicep/wipe-rg.bicep --mode complete
az keyvault purge --name $AZURE_KEYVAULT_NAME --no-wait
az keyvault wait --name $AZURE_KEYVAULT_NAME --deleted --interval 10