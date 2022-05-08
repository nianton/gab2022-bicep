param name string
param location string = resourceGroup().location
param tags object = {}
param databaseName string
param administratorLogin string = 'dbadmin'

@secure()
param administratorLoginPassword string

@description('Whether to enable Transparent Data Encryption -defaults to \'true\'')
param enableTransparentDataEncryption bool = true

param databaseEdition string = 'Standard'
param databaseServiceObjective string = 'S1'
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
  }
}

resource database 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: databaseServiceObjective
    tier: databaseEdition
  }
  properties: {
    collation: databaseCollation
  }
}

resource tde 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-02-01-preview' = {
  parent: database
  name: 'current'
  properties: {
    state: enableTransparentDataEncryption ? 'Enabled' : 'Disabled'
  }
}

output id string = sqlServer.id
output name string = sqlServer.name
output apiVersion string = sqlServer.apiVersion
output databaseId string = database.id
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
