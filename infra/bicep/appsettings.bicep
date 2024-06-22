
param websiteName string
param customSettings object = {}
param settingsType string
param existingProperties object = {}

resource website 'Microsoft.Web/sites@2023-12-01' existing  ={
  name: websiteName
}

resource configAppSettings 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: website
  name: settingsType
  properties: union(existingProperties, customSettings)
}
