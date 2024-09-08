param webAppName string
param registryName string
param location string = resourceGroup().location

resource publishingCredentials 'Microsoft.Web/sites/config@2023-12-01' existing = {
  name: '${webAppName}/publishingcredentials'
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: registryName
}

var creds = list(publishingCredentials.id, publishingCredentials.apiVersion).properties.scmUri

resource webhook 'Microsoft.ContainerRegistry/registries/webhooks@2023-07-01' = {
  parent: registry
  name: 'deployhook'
  location: location
  properties:{
    actions: [
      'push'
    ]
    serviceUri: '${creds}/docker/hook'
  }
}
