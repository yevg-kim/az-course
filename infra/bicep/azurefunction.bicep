param planName string
param appName string
param funcName string
param location string = resourceGroup().location

param uami object
param keyVaultName string

@secure()
param funcCode string 

param appSettings object = {}

resource azHostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  kind: 'windows'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
  }
  properties: {
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'azcoursefuncsa'
  location: location
  identity: uami
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  kind: 'functionapp'
  location: location
  identity: uami
  properties: {
    enabled: true
    serverFarmId: azHostingPlan.id
    siteConfig: {
      netFrameworkVersion: '8.0'
      use32BitWorkerProcess: false
      cors: {
        allowedOrigins:  ['https://portal.azure.com']
      }
    }
  }
  
  resource config 'config@2023-12-01' ={
    name: 'appsettings'
    properties: union(appSettings, {
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
      WEBSITE_CONTENTSHARE: toLower(appName)
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
    })
  }
}

resource func 'Microsoft.Web/sites/functions@2023-12-01' = {
  name: funcName
  parent: appService
  properties: {
    isDisabled: false
    config: {
      disabled: false
      bindings: [
        {
          name: 'ReserveTrigger'
          type: 'httpTrigger'
          direction: 'in'
          authLevel: 'function'
          methods: [
            'post'
          ]
        }
      ]
    }
  }
}

var keyName = 'persistent-main-key'

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'inlineCLI'
  location: location
  dependsOn: [func]
  kind: 'AzureCLI'
  identity: uami
  properties: {
    azCliVersion: '2.52.0'
    environmentVariables:[
      {
        name: 'SUBSCRIPTION'
        value: subscription().subscriptionId
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'FUNC_APP_NAME'
        value: appService.name
      }
      {
        name: 'FUNC_NAME'
        value: func.name
      }
      {
        name: 'KEY_NAME'
        value: keyName
      }
      {
        name: 'KEY_VALUE'
        value: funcCode
      }
    ]
    scriptContent: '''
    az login --identity
    az account set --subscription ${SUBSCRIPTION}
    az config set defaults.group=${RESOURCE_GROUP}
    az functionapp keys set -n ${FUNC_APP_NAME} --key-type 'functionKeys' --key-name ${KEY_NAME} --key-value ${KEY_VALUE}
    '''
    retentionInterval: 'PT1H'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource keyVaultFuncCode 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  dependsOn: [deploymentScript]
  name: 'func-code'
  properties: {
    value: funcCode
  }
}

output funcCodeKey string = keyVaultFuncCode.name
output funcUrl string = 'https://${appService.properties.defaultHostName}'
