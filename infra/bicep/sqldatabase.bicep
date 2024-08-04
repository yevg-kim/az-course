param keyVaultConnectionStringKey string
param sqlServerName string
param keyVaultName string

param dbSkuName string = 'Basic'
param databaseSuffix string = 'db'
param location string = 'northeurope'

param sqlServerLogin string
param dbLogin string
@secure()
param sqlServerPassword string
@secure()
param dbPassword string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: sqlServerName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: '${sqlServer.name}-${databaseSuffix}'
  location: location
  sku: {
    name: dbSkuName
  }     
  properties: {
    maxSizeBytes: 524288000 //500MB
  }
}

resource sqlDeploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${sqlServerDatabase.name}-deployment-script'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.37.0'
    retentionInterval: 'PT1H' // Retain the script resource for 1 hour after it ends running
    timeout: 'PT5M' // Five minutes
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'APPUSERNAME'
        value: dbLogin
      }
      {
        name: 'APPUSERPASSWORD'
        secureValue: dbPassword
      }
      {
        name: 'DBNAME'
        value: sqlServerDatabase.name
      }
      {
        name: 'DBSERVER'
        value: sqlServer.properties.fullyQualifiedDomainName
      }
      {
        name: 'SQLCMDPASSWORD'
        secureValue: sqlServerPassword
      }
      {
        name: 'SQLADMIN'
        value: sqlServerLogin
      }
    ]

    scriptContent: '''
wget https://github.com/microsoft/go-sqlcmd/releases/download/v0.8.1/sqlcmd-v0.8.1-linux-x64.tar.bz2
tar x -f sqlcmd-v0.8.1-linux-x64.tar.bz2 -C .

cat <<SCRIPT_END > ./initDb.sql
drop user if exists ${APPUSERNAME}
go
create user ${APPUSERNAME} with password = '${APPUSERPASSWORD}'
go
alter role db_owner add member ${APPUSERNAME}
go
SCRIPT_END

./sqlcmd -S ${DBSERVER} -d ${DBNAME} -U ${SQLADMIN} -i ./initDb.sql
    '''
  }
}

resource keyVaultConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: keyVaultConnectionStringKey
  properties:{
    value: 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Database=${sqlServerDatabase.name}; User=${dbLogin}; Password=${dbPassword}'
  }
}

output keyVaultConnectionStringRef string = keyVaultConnectionString.properties.secretUri
output databaseName string = sqlServerDatabase.name
