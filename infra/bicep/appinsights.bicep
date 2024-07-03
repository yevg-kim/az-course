param name string
param location string = resourceGroup().location

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' ={
  name: name
  location: location
  kind: 'web'
  properties:{
    Application_Type: 'web'
    ImmediatePurgeDataOn30Days: true
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    IngestionMode: 'ApplicationInsights'
   }
}

output id string = applicationInsights.id
output connectionString string = applicationInsights.properties.ConnectionString
