#!/bin/bash
# For local fiddling purposes
dir="$(dirname "$0")"
source ${dir}/exports.sh
az deployment group create --parameters ${dir}/bicep/parameters.bicepparam

#az deployment group validate --parameters ${dir}/bicep/parameters.bicepparam
#az deployment group create --parameters ${dir}/bicep/test/parameters.bicepparam