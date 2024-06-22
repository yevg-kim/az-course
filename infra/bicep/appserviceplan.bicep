param name string
param location string
param skuName string = 'B1'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  kind: 'linux'
  properties:{
    reserved: true
    zoneRedundant: false
  }
}

output planLocation string = location
output serverFarmId string = appServicePlan.id
