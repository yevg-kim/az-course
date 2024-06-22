param keyVaultName string
param managedIdentityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: resourceGroup().location
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: managedIdentity.properties.principalId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

output kvEndpoint string = keyVault.properties.vaultUri
output kvName string = keyVault.name
output uamiClientId string = managedIdentity.properties.clientId
output uami object = {
  type:'UserAssigned'
  userAssignedIdentities:{ '${managedIdentity.id}':{} }
}
