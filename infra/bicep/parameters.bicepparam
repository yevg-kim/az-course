using 'main.bicep'

param keyVaultName = readEnvironmentVariable('AZURE_KEYVAULT_NAME')

param primaryLocation = 'northeurope'
param secondaryLocation = 'westeurope'
param sqlServerLocation = primaryLocation

// For test purposes, passwords are set in env. variables, 
// but better alternative would be to use deployment script to generate random passwords
// and store them in the keyvault, I suppose
@secure()
param sqlServerPassword = readEnvironmentVariable('AZURE_SQL_DBA_PASS')
param sqlServerLogin = readEnvironmentVariable('AZURE_SQL_DBA_LOGIN')

@secure()
param dbPassword = readEnvironmentVariable('AZURE_SQL_APP_PASS')
param dbLogin = readEnvironmentVariable('AZURE_SQL_APP_LOGIN')

@secure()
param funcCode = readEnvironmentVariable('AZURE_FUNC_CODE')