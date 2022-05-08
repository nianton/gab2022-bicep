param keyVaultName string

@description('Array of name/value pairs')
param name string
param value string = ''
param serviceMetadata object

var deploy = (!empty(value) || !empty(serviceMetadata))
var secretValue = !empty(value) ? {
  value: value
} : serviceMetadata.type == 'storageAccount' ? {
  value : 'DefaultEndpointsProtocol=https;AccountName=${serviceMetadata.name};AccountKey=${listKeys(serviceMetadata.id, serviceMetadata.apiVersion).keys[0].value}'
} : { 
  value: '[[serviceMetadata.type was unknown]]'
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = if (deploy) {
  name: '${keyVaultName}/${name}'
  properties: {
    value: secretValue.value
  }
}

output id string = keyVaultSecret.id
output name string = name
output type string = keyVaultSecret.type
output props object = keyVaultSecret.properties
output reference string = '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${name})'
