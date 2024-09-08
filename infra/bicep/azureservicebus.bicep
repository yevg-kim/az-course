param keyVaultName string
param uami object

param serviceBusNamespaceName string
param location string = resourceGroup().location

var serviceBusQueueName = '${serviceBusNamespaceName}-queue'

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  identity: uami
  sku: {
    name: 'Standard'
  }
  properties: {}

  resource serviceBusQueue 'queues@2022-01-01-preview' = {
    name: serviceBusQueueName
    properties: {
      lockDuration: 'PT5M'
      maxSizeInMegabytes:  1024
      requiresDuplicateDetection: false
      requiresSession: false
      defaultMessageTimeToLive: 'P14D'
      deadLetteringOnMessageExpiration: true
      maxDeliveryCount: 3
      enablePartitioning: false
      enableExpress: false
    }

    resource sendRule 'authorizationRules@2022-10-01-preview' = {
      name: 'send-rule'
      properties:{
        rights: [
          'Send'
        ]
      }
    }

    resource listenRule 'authorizationRules@2022-10-01-preview' = {
      name: 'listen-rule'
      properties:{
        rights: [
          'Listen'
        ]
      }
    }
  }
}

var sendRuleResource = '${serviceBusNamespace::serviceBusQueue.id}/AuthorizationRules/${serviceBusNamespace::serviceBusQueue::sendRule.name}'
var sendRuleConnectionString = listKeys(sendRuleResource, serviceBusNamespace::serviceBusQueue.apiVersion).primaryConnectionString

resource sendRuleSecret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'send-rule-secret'
  properties: {
    value: sendRuleConnectionString
  }
}

var listenRuleResource = '${serviceBusNamespace::serviceBusQueue.id}/AuthorizationRules/${serviceBusNamespace::serviceBusQueue::listenRule.name}'
var listenRuleConnectionString = listKeys(listenRuleResource, serviceBusNamespace::serviceBusQueue.apiVersion).primaryConnectionString

resource listenRuleSecret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'listen-rule-secret'
  properties: {
    value: listenRuleConnectionString
  }
}

output sendRuleSecretUri string = sendRuleSecret.properties.secretUri
output listenRuleSecretUri string = listenRuleSecret.properties.secretUri
output queueName string = serviceBusQueueName
