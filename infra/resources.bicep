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
        targetPort: 5000
        transport: 'Auto'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/kjaymiller/aca-flask-simple:main'
          name: containerAppName
      scale: {
        maxReplicas: 10
        }
      }
    ]
    }
  }
}
