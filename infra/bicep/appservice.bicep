param name string
param location string
param serverFarmId string
param secondDeploymentSlotName string = 'not-set'
param identity object = {}
param allowedOrigins array = []
param customAppSettings object = {}

var webAppProperties = {
  serverFarmId: serverFarmId
  siteConfig:{
    linuxFxVersion:'dotnetcore|8.0'
    alwaysOn: true
    cors:{
      allowedOrigins: allowedOrigins
    }
  }
}

resource webApplication 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  kind: 'app,linux'
  identity: !empty(identity) ? identity : null
  properties: webAppProperties

  resource configAppSettings 'config@2023-12-01' = if (!empty(customAppSettings)) {
    name: 'appsettings'
    properties: union(customAppSettings, {
      SCM_DO_BUILD_DURING_DEPLOYMENT: false
      ENABLE_ORYX_BUILD: false      
    })
  }
  
  // Have to check against 'not-set' because if we check against '' validation fails
  // due to incorrect amount of segments in the name
  // even though it's under a condition.
  // And I don't know how to correctly get around that
  resource secondDeploymentSlot 'slots@2023-12-01' = if(secondDeploymentSlotName != 'not-set') {
    name: secondDeploymentSlotName
    location: location
    properties: webAppProperties
  }
}

output url string = 'https://${webApplication.properties.defaultHostName}'
output id string = webApplication.id
output name string = webApplication.name
output properties object = webApplication.properties
