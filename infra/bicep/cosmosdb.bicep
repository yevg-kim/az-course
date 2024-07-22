param name string = 'azcourse-cosmosdb-account'
param location string = resourceGroup().location

param uami object = {'':{}}
param keyVaultName string = 'not-set'

var keyVaultPresent = (keyVaultName != 'not-set')

resource cosmosDb 'Microsoft.DocumentDb/databaseAccounts@2024-05-15-preview' = {
  kind: 'MongoDB'
  name: name
  location: location
  identity: uami
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        failoverPriority: 0
        locationName: location
      }
    ]
    backupPolicy: {
      type: 'Continuous'
      continuousModeProperties: {
        tier: 'Continuous7Days'
      }
    }
    isVirtualNetworkFilterEnabled: false
    minimalTlsVersion: 'Tls12'
    capabilities: [
      {
        name: 'EnableMongo'
      }
    ]
    apiProperties: {
      serverVersion: '6.0'
    }
    capacityMode: 'Serverless'
    enableFreeTier: false
    capacity: {
      totalThroughputLimit: 4000
    }
  }

  resource db 'mongodbDatabases@2024-05-15' = {
    name: 'main-mongo-db'
    properties: {
      resource: {
        id: 'main-mongo-db'
      }
    }

    resource collection 'collections@2024-05-15' ={
      name: 'orders'
      properties: {
        resource: {
          id: 'orders'
        }
      }
    }
  }
}

var cosmosDbConnectionString = cosmosDb.listConnectionStrings().connectionStrings[0].connectionString

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = if (keyVaultPresent) {
  name: keyVaultName
}

resource connectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (keyVaultPresent) {
  parent: keyVault
  name: 'mongodb-secret'
  properties: {
    contentType: 'password'
    value: cosmosDbConnectionString
  }
}

output dbName string = cosmosDb::db.name
output connectionStringVaultRef string = keyVaultPresent ? connectionStringSecret.properties.secretUri : '' 
output keyVaultSecretName string = keyVaultPresent ? connectionStringSecret.name : ''
