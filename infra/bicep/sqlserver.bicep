param keyVaultName string

param serverName string = 'azcourse-sqlserver'
param location string = 'northeurope'

param sqlServerLogin string
param dbLogin string
@secure()
param sqlServerPassword string
@secure()
param dbPassword string


resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  properties:{
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administratorLogin: sqlServerLogin
    administratorLoginPassword: sqlServerPassword
  }

  resource firewall 'firewallRules' = {
    name: 'Azure Services'
    properties: {
      // Allow all clients
      // Note: range [0.0.0.0-0.0.0.0] means "allow all Azure-hosted clients only".
      // This is not sufficient, because we also want to allow direct access from developer machine, for debugging purposes.
      startIpAddress: '0.0.0.1'
      endIpAddress: '255.255.255.254'
    }
  }
}

var keyVaultValues = [ {
  name: 'master-db-login'
  value: sqlServerLogin
}, {
  name: 'master-db-password'
  value: sqlServerPassword
}, {
  name: 'app-db-login'
  value: dbLogin
}, {
  name: 'app-db-password'
  value: dbPassword
},]

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [for entry in keyVaultValues: {
  parent: keyVault
  name: entry.name
  properties:{
    value: entry.value
  }
}]

output name string = sqlServer.name
