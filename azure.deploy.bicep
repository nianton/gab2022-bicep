targetScope = 'subscription'

@description('Resource group name (optional), one will be created based if not provided')
param resourceGroupName string = ''
param location string
param applicationName string
param environment string
param tags object = {}

@secure()
param jumphostAdministratorPassword string

@secure()
param sqlServerAdministratorPassword string

var defaultTags = union({
  applicationName: applicationName
  environment: environment
}, tags)

var rgName = empty(resourceGroupName) ? 'rg-${applicationName}-${environment}' : resourceGroupName

// Resource group which is the scope for the main deployment below
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: defaultTags
}

// Naming module to configure the naming conventions for Azure
module naming 'modules/naming.module.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'NamingDeployment'  
  params: {
    suffix: [
      applicationName
      environment
    ]
    uniqueLength: 6
    uniqueSeed: rg.id
  }
}

// Main deployment has all the resources to be deployed for 
// a workload in the scope of the specific resource group
module main 'main.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'MainDeployment'
  params: {
    location: location
    naming: naming.outputs.names
    jumphostAdministratorPassword: jumphostAdministratorPassword
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
    tags: defaultTags
  }
}

// Customize outputs as required from the main deployment module
output resourceGroupId string = rg.id
output resourceGroupName string = rg.name
output frontendWebApp object = main.outputs.frontendWebApp
output backendWebApp object = main.outputs.backendWebApp
output storageAccountName string = main.outputs.storageAccountName
