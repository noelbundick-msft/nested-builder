targetScope = 'subscription'

param location string = 'westus3'

resource builderRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'builder'
  location: location
}

resource imagesRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'images'
  location: location
}

module builder 'builder.bicep' = {
  name: 'builder'
  scope: builderRG
  params: {
    location: location
    adminPassword: 'Password#1234'
  }
}

module storage 'storage.bicep' = {
  name: 'storage'
  scope: builderRG
  params: {
    location: location
    principalId: builder.outputs.principalId
  }
}
