targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name to prefix all resources')
param name string = 'aca-tweet-scheduler'

@minLength(1)
@description('Primary location for all resources')
param location string = 'westus'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-resource-group'
  location: location
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    name: name
    location: location
   }
}
