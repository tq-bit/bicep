param webApplicationName string = 'tqbit-node-red-app'
param serverFarmResourceName string = 'tqbit-serverfarm-01'
param location string = resourceGroup().location
param enableFileAccess bool = true

resource ServerFarmResource 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: serverFarmResourceName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
    size: 'F1'
    family: 'F'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource WebApplicationResource 'Microsoft.Web/sites@2023-01-01' = {
  name: webApplicationName
  location: location
  kind: 'app,linux,container'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webApplicationName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webApplicationName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: ServerFarmResource.id
    reserved: true
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOCKER|nodered/node-red:latest'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '4BC66C5FBC5048DC2AA4B47E265E1F00D4F5ABE921C136B74B2A462C4C1B9DF2'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource WebApplicationAllowFtp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: WebApplicationResource
  name: 'ftp'
  properties: {
    allow: enableFileAccess
  }
}

resource WebApplicationAllowScm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: WebApplicationResource
  name: 'scm'
  properties: {
    allow: enableFileAccess
  }
}



resource WebApplicationConfiguration 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: WebApplicationResource
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOCKER|nodered/node-red:latest'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$tqbit-node-red-app'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource WebApplicationConfigurationHostNameBinding 'Microsoft.Web/sites/hostNameBindings@2023-01-01' = {
  parent: WebApplicationResource
  name: '${webApplicationName}.azurewebsites.net'
  properties: {
    siteName: webApplicationName
    hostNameType: 'Verified'
  }
}
