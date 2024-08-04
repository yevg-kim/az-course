param keyVaultName string

param primaryLocation string
param secondaryLocation string
param sqlServerLocation string

param sqlServerLogin string
param dbLogin string

@secure()
param sqlServerPassword string
@secure()
param dbPassword string
@secure()
param funcCode string
param deploymentSuffix string = substring(newGuid(), 0, 8)

var resourcePrefix = 'azcourseA9J523I-'

module primaryAppServicePlan 'appserviceplan.bicep' = {
  name: 'primaryAspDeployment-${deploymentSuffix}'
  params:{
    name: '${resourcePrefix}primary-service-plan'
    location: primaryLocation
    skuName: 'S1'
  }
}

module secondaryAppServicePlan 'appserviceplan.bicep' = {
  name: 'secondaryAspDeployment-${deploymentSuffix}'
  params:{
    name: '${resourcePrefix}secondary-service-plan'
    location: secondaryLocation
    skuName: 'S1'
  }
}

var webAppCommonSettings = union (appInsightsSettings, {
  ASPNETCORE_ENVIRONMENT:'Production'
  AZURE_CLIENT_ID: keyVaultAndUami.outputs.uamiClientId
  AZURE_SQL_IDENTITY_CONNECTION_STRING: '@Microsoft.KeyVault(SecretUri=${db[0].outputs.keyVaultConnectionStringRef})' 
  AZURE_SQL_CATALOG_CONNECTION_STRING: '@Microsoft.KeyVault(SecretUri=${db[1].outputs.keyVaultConnectionStringRef})'
  CUSTOM_RESERVE_SERVICE_ENDPOINT: azureFunction.outputs.funcUrl
  AZURE_FUNCTION_CODE: '@Microsoft.KeyVault(SecretUri=${azureFunction.outputs.funcCodeRef})' //azureFunction.outputs.funcCodeKey
  AZURE_KEY_VAULT_ENDPOINT: keyVaultAndUami.outputs.kvEndpoint
  CUSTOM_PUBLIC_API_ENDPOINT: publicApi.outputs.url
})

module applicationInsights 'appinsights.bicep' = {
  name: 'applicationInsightsDeployment-${deploymentSuffix}'
  params:{
    name: '${resourcePrefix}app-insights'
  }
}

var appInsightsSettings = {
  APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.outputs.id
  ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
  APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.outputs.connectionString
}

module primaryWebApp 'appservice.bicep' = {
  name: 'primaryWebAppDeployment-${deploymentSuffix}'
  params:{
    name: '${resourcePrefix}web-app-primary'
    location: primaryAppServicePlan.outputs.planLocation
    serverFarmId: primaryAppServicePlan.outputs.serverFarmId
    secondDeploymentSlotName: 'staging'
    customAppSettings: webAppCommonSettings
    identity: keyVaultAndUami.outputs.uami
  }
}

module azureFunction 'azurefunction.bicep' = {
  name: 'appFunctionDeployment-${deploymentSuffix}'
  params:{
    appName:'${resourcePrefix}func-app'
    planName:'${resourcePrefix}func-plan'
    funcName:'${resourcePrefix}func'
    funcCode: funcCode
    keyVaultName: keyVaultAndUami.outputs.kvName
    uami: keyVaultAndUami.outputs.uami
    location:primaryLocation
    appSettings: union(appInsightsSettings, {
      COSMOSDB_CONNECTION_STRING: '@Microsoft.KeyVault(SecretUri=${cosmosDb.outputs.connectionStringVaultRef})'
      COSMOSDB_DATABASE: cosmosDb.outputs.dbName
    })
  }
}

module secondaryWebApp 'appservice.bicep' = {
  name: 'secondaryWebAppDeployment-${deploymentSuffix}'
  params:{
    name: '${resourcePrefix}web-app-secondary'
    location: secondaryAppServicePlan.outputs.planLocation
    serverFarmId: secondaryAppServicePlan.outputs.serverFarmId
    customAppSettings: webAppCommonSettings
    identity: keyVaultAndUami.outputs.uami
  }
}

module publicApi 'appservice.bicep' = {
  name: 'publicApiDeployment-${deploymentSuffix}'
  params:{
    name: '${resourcePrefix}public-api'
    location: primaryAppServicePlan.outputs.planLocation
    serverFarmId: primaryAppServicePlan.outputs.serverFarmId
    identity: keyVaultAndUami.outputs.uami
    customAppSettings: union(appInsightsSettings, {
      UseOnlyInMemoryDatabase:true
    })
  }
}

module publicApiSettings 'appsettings.bicep' = {
  name: 'publicApiSettingsDeployment-${deploymentSuffix}'
  params: {
    websiteName: publicApi.outputs.name
    settingsType: 'web'
    existingProperties: publicApi.outputs.properties
    customSettings: {
      cors:{
        allowedOrigins: [primaryWebApp.outputs.url, secondaryWebApp.outputs.url]
      }
    }
  }
}

module keyVaultAndUami 'keyvault.bicep' = {
  name: 'keyVaultAndManagedIdentityDeployment-${deploymentSuffix}'
  params:{
    keyVaultName: keyVaultName
    managedIdentityName: '${resourcePrefix}managed-identity'
  }
}

module cosmosDb 'cosmosdb.bicep' = {
  name: 'cosmosDbDeployment-${deploymentSuffix}'
  params:{
    keyVaultName: keyVaultAndUami.outputs.kvName
    location: primaryLocation
    name: 'azcourse-cosmosdb-account'
    uami: keyVaultAndUami.outputs.uami
  }
}

module sqlServer 'sqlserver.bicep' = {
  name: 'sqlServerDeployment-${deploymentSuffix}'
  params: {
    location: sqlServerLocation
    dbLogin: dbLogin
    dbPassword: dbPassword
    sqlServerLogin: sqlServerLogin
    sqlServerPassword: sqlServerPassword
    keyVaultName: keyVaultAndUami.outputs.kvName
  }
}

var databaseParams = [{
  name: 'identityDb'
  suffix: 'identityDb'
  connectionStringKey: 'azure-keyvault-identity-connection-string'
},{
  name: 'mainDb'
  suffix: 'mainDb'
  connectionStringKey: 'azure-keyvault-main-connection-string'
},]

module db 'sqldatabase.bicep' = [for database in databaseParams: {
  name: '${database.name}Deployment-${deploymentSuffix}'
  params: {
    sqlServerName: sqlServer.outputs.name
    location: sqlServerLocation
    dbLogin: dbLogin
    dbPassword: dbPassword
    sqlServerLogin: sqlServerLogin
    sqlServerPassword: sqlServerPassword
    databaseSuffix: database.suffix
    keyVaultConnectionStringKey: database.connectionStringKey
    keyVaultName: keyVaultAndUami.outputs.kvName
  }
}]

module trafficManager 'trafficmanager.bicep' = {
  name: 'trafficManagerDeployment-${deploymentSuffix}'
  params: {
    name: '${resourcePrefix}traffic-manager'
    url: '${resourcePrefix}tm'
    endpoints: [
      {
        id: primaryWebApp.outputs.id
        url: primaryWebApp.outputs.url
        priority: 1
      }, {
        id: secondaryWebApp.outputs.id
        url: secondaryWebApp.outputs.url
        priority: 2
      }]
  }
}

module autoScale 'autoscale.bicep' = {
  name: 'autoScaleDeployment-${deploymentSuffix}'
  params: {
    location: primaryAppServicePlan.outputs.planLocation
    name: '${resourcePrefix}auto-scale'
    planId: primaryAppServicePlan.outputs.serverFarmId
    sendNotificationTo: ['yevgeniy_kim@epam.com']
    cpuThreshold: 80
    scaleByInstances: 1
  }
}

output publicApiUrl string = publicApi.outputs.url
output primaryWebAppUrl string = primaryWebApp.outputs.url
output secondaryWebAppUrl string = secondaryWebApp.outputs.url
output trafficManagerUrl string = trafficManager.outputs.url
