param keyVaultName string

@description('Array of name/value pairs')
param secrets array

module keyVaultSecrets 'keyvault.secret.module.bicep' = [for secret in secrets: {
  name: 'keyVaultSecret-${secret.name}-Deployment'
  params: {
    keyVaultName: keyVaultName
    name: secret.name    
    value: contains(secret, 'value') ? secret.value : ''
    serviceMetadata: contains(secret, 'service') ? secret.service : {}
  }
}]

output secrets array = [for (item, i) in secrets: keyVaultSecrets[i]]
