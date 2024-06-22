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

var resourcePrefix = 'azcourse-'

module primaryAppServicePlan 'appserviceplan.bicep' = {
  name: 'primaryAspDeployment'
  params:{
    name: '${resourcePrefix}primary-service-plan'
    location: primaryLocation
    skuName: 'S1'
  }
}

module secondaryAppServicePlan 'appserviceplan.bicep' = {
  name: 'secondaryAspDeployment'
  params:{
    name: '${resourcePrefix}secondary-service-plan'
    location: secondaryLocation
    skuName: 'S1'
  }
}

var webAppCommonSettings = {
  ASPNETCORE_ENVIRONMENT:'Production'
  AZURE_CLIENT_ID: keyVaultAndUami.outputs.uamiClientId
  AZURE_SQL_IDENTITY_CONNECTION_STRING_KEY: db[0].outputs.keyVaultConnectionStringKey
  AZURE_SQL_CATALOG_CONNECTION_STRING_KEY: db[1].outputs.keyVaultConnectionStringKey
  AZURE_KEY_VAULT_ENDPOINT: keyVaultAndUami.outputs.kvEndpoint
  CUSTOM_PUBLIC_API_ENDPOINT: publicApi.outputs.url
}

module primaryWebApp 'appservice.bicep' = {
  name: 'primaryWebAppDeployment'
  params:{
    name: '${resourcePrefix}web-app-primary'
    location: primaryAppServicePlan.outputs.planLocation
    serverFarmId: primaryAppServicePlan.outputs.serverFarmId
    secondDeploymentSlotName: 'staging'
    customAppSettings: webAppCommonSettings
    identity: keyVaultAndUami.outputs.uami
  }
}

module secondaryWebApp 'appservice.bicep' = {
  name: 'secondaryWebAppDeployment'
  params:{
    name: '${resourcePrefix}web-app-secondary'
    location: secondaryAppServicePlan.outputs.planLocation
    serverFarmId: secondaryAppServicePlan.outputs.serverFarmId
    customAppSettings: webAppCommonSettings
    identity: keyVaultAndUami.outputs.uami
  }
}

module publicApi 'appservice.bicep' = {
  name: 'publicApiDeployment'
  params:{
    name: '${resourcePrefix}public-api'
    location: primaryAppServicePlan.outputs.planLocation
    serverFarmId: primaryAppServicePlan.outputs.serverFarmId
    customAppSettings: {
      UseOnlyInMemoryDatabase:true
    }
  }
}

module publicApiSettings 'appsettings.bicep' = {
  name: 'publicApiSettingsDeployment'
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
  name: 'keyVaultAndManagedIdentityDeployment'
  params:{
    keyVaultName: keyVaultName
    managedIdentityName: '${resourcePrefix}managed-identity'
  }
}

module sqlServer 'sqlserver.bicep' = {
  name: 'sqlServerDeployment'
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
  name: '${database.name}Deployment'
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
  name: 'trafficManagerDeployment'
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
  name: 'autoScaleDeployment'
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
