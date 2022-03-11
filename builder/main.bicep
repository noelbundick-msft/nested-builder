targetScope = 'subscription'

param location string = 'westus3'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'builder'
  location: location
}

module builder 'builder.bicep' = {
  name: 'builder'
  scope: rg
  params: {
    location: location
    adminPassword: 'Password#1234'
  }
}

module storage 'storage.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    location: location
    principalId: builder.outputs.principalId
  }
}
