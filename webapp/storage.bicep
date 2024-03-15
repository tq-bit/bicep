param storageAccountName string = 'tqbitstorage01'
param location string = resourceGroup().location

resource StorageAccountResource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource StorageAccountBlobServiceResource 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: StorageAccountResource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource StorageAccountFileServicesResource 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: StorageAccountResource
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource StorageAccountFileServicesShareResource 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: StorageAccountFileServicesResource
  name: '${storageAccountName}fileservice01'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
}

resource StorageAccountQueueServiceResource 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: StorageAccountResource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource StorageAccountTableServiceResource 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: StorageAccountResource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}
