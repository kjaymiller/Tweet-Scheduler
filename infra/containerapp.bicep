param containerAppName string
param containerEnvId string
param containerRegistryName string
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: '${resourceGroup().name}-identity'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  name: containerRegistryName
}

resource containerApp 'Microsoft.App/containerapps@2022-03-01' = {
name: containerAppName
tags: {'azd-service-name': 'web'}
location: location
identity: {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${managedIdentity.id}' : {}
  }
}
properties: {
  managedEnvironmentId: containerEnvId
  configuration: {
    activeRevisionsMode: 'Single'
    ingress: {
      external: true
      targetPort: 8000
      transport: 'Auto'
      allowInsecure: false
    }
    registries: [
      {
        server: containerRegistry.properties.loginServer
        identity: managedIdentity.id
      }
    ]
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
        image: '${containerRegistry.name}.azurecr.io/'
        name: containerAppName
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
