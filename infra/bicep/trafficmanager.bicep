param name string
param url string
param endpoints array

var endpointsSettings = map(endpoints, (ep, ind) => {
  type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
  name: 'endpoint${ind}'
  properties:{
    alwaysServe: 'Disabled'
    endpointStatus:'Enabled' 
    targetResourceId: ep.id
    target: ep.url
    priority: ep.priority
  }
})

resource trafficManagerProfile 'Microsoft.Network/trafficmanagerprofiles@2022-04-01' ={
  name: name
  location: 'global'
  properties:{
    monitorConfig:{
      path: '/health'
      protocol: 'HTTPS'
      port: 443
      timeoutInSeconds: 10
      intervalInSeconds:30
      toleratedNumberOfFailures: 5
    }
    dnsConfig:{
      relativeName: url
      ttl: 60
    }
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    endpoints: endpointsSettings
  }
}

output url string = trafficManagerProfile.properties.dnsConfig.fqdn
