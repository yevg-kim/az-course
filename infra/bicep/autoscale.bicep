param name string
param location string
param planId string
param cpuThreshold int = 90
param scaleByInstances int = 1
param sendNotificationTo array

var conciseRules = [
  {
    operator: 'GreaterThanOrEqual'
    threshold: cpuThreshold
    action: 'Increase'
  },{
    operator: 'LessThan'
    threshold: cpuThreshold
    action: 'Decrease'
  }
]

var rules = map(conciseRules, rule => {
  metricTrigger: {
    metricNamespace: 'microsoft.web/serverfarms'
    metricResourceUri: planId
    metricName: 'CpuPercentage'
    operator: rule.operator
    statistic: 'Average'
    threshold: rule.threshold
    timeAggregation: 'Average'
    timeGrain: 'PT1M'
    timeWindow: 'PT5M'
  }
  scaleAction: {
    cooldown: 'PT5M'
    direction: rule.action
    type: 'ChangeCount'
    value: string(scaleByInstances)
  }
})

resource autoScale 'Microsoft.Insights/autoscalesettings@2022-10-01' ={
  name: name
  location: location
  properties: {
    name: name
    enabled: true
    targetResourceUri: planId
    targetResourceLocation: location
    notifications:[
      {
        operation: 'Scale'
        email:{
          customEmails: sendNotificationTo
        }
      }
    ]
    profiles: [
      {
        name: 'main-profile'
        capacity: {
          default: '1'
          maximum: '2'
          minimum: '1'
        }
        rules: rules
        fixedDate:{
          timeZone: 'UTC'
          start: '2024-06-21T00:00:00.000Z'
          end: '2024-12-31T23:59:00.000Z'
        }
      }
    ]
  }
}
