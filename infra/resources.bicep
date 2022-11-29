param name string
param location string = resourceGroup().location

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var containerAppName = '${name}-container-app'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${name}-workspace'
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}


resource containerEnv 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${name}-container-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

resource containerApp 'Microsoft.App/containerapps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: containerEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8000
        transport: 'Auto'
        allowInsecure: false
      }
      secrets: [
            {
              name: 'twitter-consumer-key'
              value: 'twitterConsumerKey'
            }
            {
              name: 'twitter-consumer-secret'
              value: 'twitterConsumerSecret'
            }
            {
              name: 'twitter-access-token'
              value: 'twitterAccessToken'
            }
            {
              name: 'twitter-access-token-secret'
              value: 'twitterAccessTokenSecret'
            }
      ]
    }
    template: {
      containers: [
        {
          image: 'jmtweetschedule8675.azurecr.io/jmtweetscheduler'
          name: containerAppName
          scale: {
            maxReplicas: 10
          }
          env: [
            {
              name: 'twitterconsumerkey'
              secretRef: 'twitter-consumer-key'
            }
            {
              name: 'twitterconsumersecret'
              secretRef: 'twitter-consumer-secret'
            }
            {
              name: 'twitteraccesstoken'
              secretRef: 'twitter-access-token'
            }
            {
              name: 'twitteraccesstokensecret'
              secretRef: 'twitter-access-token-secret'
            }
          ]
        }
      ]
    }
  }
}
