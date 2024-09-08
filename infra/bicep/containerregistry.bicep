param name string
param location string = resourceGroup().location

param uami object
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}
resource registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: name
  location: location
  identity: uami
  sku: {
    name: 'Basic'
  }
  properties:{
    adminUserEnabled: true
  }
}

resource adminUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'cr-admin-username'
  properties: {
    value: registry.listCredentials().username
  }
}

resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'cr-admin-password'
  properties: { 
    value: registry.listCredentials().passwords[0].value
  }
}

output registryName string = registry.name
output registryUri string = registry.properties.loginServer
output adminUsernameRef string = adminUsernameSecret.properties.secretUri
output adminPasswordRef string = adminPasswordSecret.properties.secretUri

