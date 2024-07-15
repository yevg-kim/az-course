#!/bin/bash
# For local fiddling purposes
script_dir="$(dirname "$0")"
base_folder="$script_dir/.."
artifact_web="$base_folder/publish-web"
artifact_public_api="$base_folder/publish-public-api"
artifact_reserve_func="$base_folder/publish-reserve-func"

artifact=$artifact_web
find $base_folder -type d -wholename "$artifact*" -exec rm -rf {} +
dotnet publish "$base_folder/src/Web/Web.csproj" --configuration Release -o "$artifact/" -r 'linux-x64'
7z a "$artifact.zip" "$artifact/*" "-o$base_folder"
az webapp deploy --clean --src-path "$artifact.zip" --name 'azcourse-web-app-primary' --verbose

artifact=$artifact_public_api
find $base_folder -type d -wholename "$artifact*" -exec rm -rf {} +
dotnet publish "$base_folder/src/PublicApi/PublicApi.csproj" --configuration Release -o "$artifact/" -r 'linux-x64'
7z a "$artifact.zip" "$artifact/*" "-o$base_folder"
az webapp deploy --clean --src-path "$artifact.zip" --name 'azcourse-public-api' --verbose

artifact=$artifact_reserve_func
find $base_folder -type d -wholename "$artifact*" -exec rm -rf {} +
dotnet publish "$base_folder/src/ReserveFunctionApp/ReserveFunctionApp.csproj" --configuration Release -o "$artifact/" -r 'win-x64'
7z a "$artifact.zip" "$artifact/*" "-o$base_folder"
az functionapp deployment source config-zip -n 'azcourse-func-app' --src "$artifact.zip"